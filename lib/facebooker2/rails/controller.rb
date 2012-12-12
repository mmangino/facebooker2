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
        if (Facebooker2.oauth2)
          oauth2_fetch_client_and_user
        else
          fetch_client_and_user
        end
        @_current_facebook_user
      end
      
      def current_facebook_client
        if (Facebooker2.oauth2)
          oauth2_fetch_client_and_user
        else
          fetch_client_and_user
        end
        @_current_facebook_client
      end
      
      # This mimics the getSession logic from the php facebook SDK
      # https://github.com/facebook/php-sdk/blob/master/src/facebook.php#L333
      #
      def fetch_client_and_user
        return if @_fb_user_fetched
        # Try to authenticate from the signed request first
        sig = fetch_client_and_user_from_signed_request
        sig = fetch_client_and_user_from_cookie if @_current_facebook_client.nil? and !signed_request_from_logged_out_user?
        
        #write the authentication params to a new cookie
        if !@_current_facebook_client.nil? 
          #we may have generated the signature based on the params in @facebook_params, and the expiration here is different
          
          set_fb_cookie(@_current_facebook_client.access_token, @_current_facebook_client.expiration, @_current_facebook_user.id, sig)
        else
          # if we do not have a client, delete the cookie
          set_fb_cookie(nil,nil,nil,nil)
        end
        
        @_fb_user_fetched = true
      end
      
      def fetch_client_and_user_from_cookie
        if (hash_data = fb_cookie_hash) and
          fb_cookie_signature_correct?(fb_cookie_hash,Facebooker2.secret)
          fb_create_user_and_client(hash_data["access_token"],hash_data["expires"],hash_data["uid"])
          return fb_cookie_hash["sig"]
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
      
      def fb_cookie_hash
        return nil unless fb_cookie?
        hash={}
        data = fb_cookie.gsub(/"/,"")
        data.split("&").each do |str|
          parts = str.split("=")
          hash[parts.first] = parts.last
        end
        hash
      end
      
      def fb_cookie?
        !fb_cookie.blank?
      end
      
      def fb_cookie
        cookies[fb_cookie_name]
      end
      
      def fb_cookie_name
        return "#{Facebooker2.cookie_prefix + Facebooker2.app_id.to_s}"
      end
      
      # check if the expected signature matches the one from facebook
      def fb_cookie_signature_correct?(hash,secret)
        generate_signature(hash,secret) == hash["sig"]
      end
      
      # If the signed request is valid but contains no oauth token,
      # the user is either logged out from Facebook or has not authorized the app
      def signed_request_from_logged_out_user?
        !facebook_params.empty? && facebook_params[:oauth_token].nil?
      end
      
      # compute the md5 sig based on access_token,expires,uid, and the app secret
      def generate_signature(hash,secret)
        sorted_keys = hash.keys.reject {|k| k=="sig"}.sort
        test_string = ""
        sorted_keys.each do |key|
          test_string += "#{key}=#{hash[key]}"
        end
        test_string += secret
        sig = Digest::MD5.hexdigest(test_string)
        return sig
      end
      
      def fb_signed_request_json(encoded)
        chars_to_add = 4-(encoded.size % 4)
        encoded += ("=" * chars_to_add)
        base64_url_decode(encoded)
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
          
          if @_current_facebook_client
            #compute a signature so we can store it in the cookie
            sig_hash = Hash["uid"=>facebook_params[:user_id],"access_token"=>facebook_params[:oauth_token],"expires"=>facebook_params[:expires]]
            return generate_signature(sig_hash, Facebooker2.secret)
          end
        end
      end
      
      
      # /**
      #   This method was shamelessly stolen from the php facebook SDK:
      #   https://github.com/facebook/php-sdk/blob/master/src/facebook.php
      #   
      #    Set a JS Cookie based on the _passed in_ session. It does not use the
      #    currently stored session -- you need to explicitly pass it in.
      #   
      #   If a nil access_token is passed in this method will actually delete the fbs_ cookie
      #
      #   */
      def set_fb_cookie(access_token,expires,uid,sig) 
        
        #default values for the cookie
        value = 'deleted'
        expires = Time.now.utc - 3600 unless expires != nil

        # If the expires value is set to some large value in the future, then the 'offline access' permission has been
        # granted.  In the Facebook JS SDK, this causes a value of 0 to be set for the expires parameter.  This value 
        # needs to be correct otherwise the request signing fails, so if the expires parameter retrieved from the graph
        # api is more than a year in the future, then we set expires to 0 to match the JS SDK.
        expires = 0 if expires > Time.now + 1.year
        
        if access_token
          # Retrieve the existing cookie data
          data = fb_cookie_hash || {}
          # Remove the deleted value if this has previously been set, as we don't want to include it as part of the 
          # request signing parameters
          data.delete('deleted') if data.key?('deleted')
          # Keep existing cookie data that could have been set by FB JS SDK
          data.merge!('access_token' => access_token, 'uid' => uid, 'sig' => sig, 'expires' => expires.to_i.to_s)
          # Create string to store in cookie
          value = '"'
          data.each do |k,v|
            value += "#{k.to_s}=#{v.to_s}&"
          end
          value.chop!
          value+='"'
        end
  
        # if an existing cookie is not set, we dont need to delete it
        if (value == 'deleted' && (!fb_cookie? || fb_cookie == "" ))
          return;
        end
        
        #My browser doesn't seem to save the cookie if I set expires
        cookies[fb_cookie_name] = { :value=>value }#, :expires=>expires}
      end
      
    
      # For canvas apps, You need to set the p3p header in order to get IE 6/7 to accept the third-party cookie
      # For details http://www.softwareprojects.com/resources/programming/t-how-to-get-internet-explorer-to-use-cookies-inside-1612.html
      def set_p3p_header_for_third_party_cookies
        response.headers['P3P'] = 'CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"'
      end

      ### Oauth2

      def oauth2_fetch_client_and_user
        return if @_fb_user_fetched
        oauth2_fetch_client_and_user_from_session || oauth2_fetch_client_and_user_from_cookie
        @_fb_user_fetched = true
      end

      def oauth2_fetch_client_and_user_from_cookie
        return unless fb_cookie?
        sig,payload = fb_cookie.split('.')
        return unless fb_signed_request_sig_valid?(sig, payload)
        data = JSON.parse(base64_url_decode(payload))
        authenticator = Mogli::Authenticator.new(Facebooker2.app_id, Facebooker2.secret, '')
        client = Mogli::Client.create_from_code_and_authenticator(data["code"], authenticator)
        user = Mogli::User.new(:id=>data["user_id"])
        oauth2_store_client_and_user_in_session(client,user)
        fb_sign_in_user_and_client(user, client)
      end

      def oauth2_store_client_and_user_in_session(client, user)
        session[:facebooker2_access_token] = client.access_token
        session[:facebooker2_expiration] = client.expiration
        session[:facebooker2_user_id] = user.id
      end

      def oauth2_fetch_client_and_user_from_session
        if session[:facebooker2_access_token]
          client = Mogli::Client.new(session[:facebooker2_access_token],session[:facebooker2_expiration])
          user = Moglie::User.new(:id=>session[:facebooker2_user_id])
          sign_in_user_and_client(user, client)
        end
      end


      def base64_url_decode(encoded)
        chars_to_add = 4-(encoded.size % 4)
        encoded += ("=" * chars_to_add)
        Base64.decode64(encoded.tr("-_", "+/"))
      end

    end
  end
end
