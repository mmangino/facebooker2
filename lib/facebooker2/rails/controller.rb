require "digest/md5"
require "hmac-sha2"
module Facebooker2
  module Rails
    module Controller
      
      def self.included(controller)
        controller.helper Facebooker2::Rails::Helpers
        controller.helper_method :current_facebook_user
        controller.helper_method :current_facebook_client
        controller.helper_method :facebook_params
      end
      
      def current_facebook_user
        fetch_client_and_user
        @_current_facebook_user
      end
      
      def current_facebook_client
        fetch_client_and_user
        @_current_facebook_client
      end
      
      def fetch_client_and_user
        return if @_fb_user_fetched
        fetch_client_and_user_from_cookie
        fetch_client_and_user_from_signed_request unless @_current_facebook_client
        @_fb_user_fetched = true
      end
      
      def fetch_client_and_user_from_cookie
        app_id = Facebooker2.app_id
        if (hash_data = fb_cookie_hash_for_app_id(app_id)) and
          fb_cookie_signature_correct?(fb_cookie_hash_for_app_id(app_id),Facebooker2.secret)
          fb_create_user_and_client(hash_data["access_token"],hash_data["expires"],hash_data["uid"])
        end
      end
      
      def fb_create_user_and_client(token,expires,userid)
        client = Mogli::Client.new(token,expires.to_i)
        user = Mogli::User.new(:id=>userid)
        fb_sign_in_user_and_client(user,client)        
      end
            
      def fb_sign_in_user_and_client(user,client)
        user.client = client
        @_current_facebook_user = user
        @_current_facebook_client = client
        @_fb_user_fetched = true
      end
      
      def fb_cookie_hash_for_app_id(app_id)
        return nil unless fb_cookie_for_app_id?(app_id)
        hash={}
        data = fb_cookie_for_app_id(app_id).gsub(/"/,"")
        data.split("&").each do |str|
          parts = str.split("=")
          hash[parts.first] = parts.last
        end
        hash
      end
      
      def fb_cookie_for_app_id?(app_id)
        !fb_cookie_for_app_id(app_id).nil?
      end
      
      def fb_cookie_for_app_id(app_id)
        cookies["fbs_#{app_id}"]
      end
      
      def fb_cookie_signature_correct?(hash,secret)
        sorted_keys = hash.keys.reject {|k| k=="sig"}.sort
        test_string = ""
        sorted_keys.each do |key|
          test_string += "#{key}=#{hash[key]}"
        end
        test_string += secret
        Digest::MD5.hexdigest(test_string) == hash["sig"]
      end
      
      def fb_signed_request_json(encoded)
        chars_to_add = 4-(encoded.size % 4)
        encoded += ("=" * chars_to_add)
        Base64.decode64(encoded)
      end
      
      def facebook_params
        @facebook_param ||= fb_load_facebook_params
      end

      def fb_load_facebook_params
        return {} if params[:signed_request].blank?
        sig,encoded_json = params[:signed_request].split(".")
        return {} unless fb_signed_request_sig_valid?(sig,encoded_json)
        ActiveSupport::JSON.decode(fb_signed_request_json(encoded_json)).with_indifferent_access
      end  
      
      def fb_signed_request_sig_valid?(sig,encoded) 
        base64 = Base64.encode64(HMAC::SHA256.digest(Facebooker2.secret,encoded))
        #now make the url changes that facebook makes
        url_escaped_base64 = base64.gsub(/=*\n?$/,"").tr("+/","-_")
        sig ==  url_escaped_base64
      end
      
      def fetch_client_and_user_from_signed_request
        if facebook_params[:oauth_token]
          fb_create_user_and_client(facebook_params[:oauth_token],facebook_params[:expires],facebook_params[:user_id])
        end
      end
    end
  end
end
