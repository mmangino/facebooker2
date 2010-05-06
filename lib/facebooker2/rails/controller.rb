require "digest/md5"
require "ruby-debug"
module Facebooker2
  module Rails
    module Controller
      
      def self.included(controller)
        controller.helper Facebooker2::Rails::Helpers
        controller.helper_method :current_facebook_user
        controller.helper_method :current_facebook_client
      end
      
      def current_facebook_user
        fetch_client_and_user_from_cookie
        @_current_facebook_user
      end
      
      def current_facebook_client
        fetch_client_and_user_from_cookie
        @_current_facebook_client
      end
      
      def fetch_client_and_user_from_cookie
        return if @_fb_user_fetched
        app_id = Facebooker2.app_id
        if (hash_data = fb_cookie_hash_for_app_id(app_id)) and
          fb_cookie_signature_correct?(fb_cookie_hash_for_app_id(app_id),Facebooker2.secret)
          client = Mogli::Client.new(hash_data["access_token"],hash_data["expires"].to_i)
          user = Mogli::User.new(:id=>hash_data["uid"])
          user.client = @_current_facebook_client
          fb_sign_in_user_and_client(user,client)
        end
        @_fb_user_fetched = true
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
    end
  end
end