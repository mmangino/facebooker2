module Facebooker2
  module Rails
    module Helpers
      module Javascript
        
        def fb_html_safe(str)
          if str.respond_to?(:html_safe)
            str.html_safe
          else
            str
          end
        end
        
        def fb_connect_async_js(app_id=Facebooker2.app_id,options={},&proc)
          opts = Hash.new.merge!(options)
          cookie = opts[:cookie].nil? ? true : opts[:cookie]
          status = opts[:status].nil? ? true : opts[:status]
          xfbml = opts[:xfbml].nil?   ? true : opts[:xfbml]
          music = opts[:music].nil?   ? false : opts[:music]
          channel_url = opts[:channel_url]
          lang = opts[:locale] || 'en_US'
          extra_js = capture(&proc) if block_given?
          js = <<-JAVASCRIPT
          <div id="fb-root"></div>
          <script>
            window.fbAsyncInit = function() {
              FB.init({
                appId  : '#{app_id}',
                status : #{status}, // check login status
                cookie : #{cookie}, // enable cookies to allow the server to access the session
                #{"channelUrl : '#{channel_url}', // add channelURL to avoid IE redirect problems" unless channel_url.blank?}
                oauth : true,
                music : #{music}, //turn on music for OG
                xfbml  : #{xfbml}  // parse XFBML
              });
              #{extra_js}
            };

            (function() {
              var e = document.createElement('script'); e.async = true;
              e.src = document.location.protocol + '//connect.facebook.net/#{lang}/all.js';
              document.getElementById('fb-root').appendChild(e);
            }());
          </script>
          JAVASCRIPT
          escaped_js = fb_html_safe(js)
          if block_given? 
           concat(escaped_js)
           #return the empty string, since concat returns the buffer and we don't want double output
           # from klochner
           "" 
          else
           escaped_js
          end
        end
      end
    end
  end
end
