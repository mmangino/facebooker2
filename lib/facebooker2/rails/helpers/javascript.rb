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
          opts = Hash.new(true).merge!(options)
          cookie = opts[:cookie]
          status = opts[:status]
          xfbml = opts[:xfbml]
          extra_js = capture(&proc) if block_given?
          js = <<-JAVASCRIPT
          <script>
            window.fbAsyncInit = function() {
              FB.init({
                appId  : '#{app_id}',
                status : #{status}, // check login status
                cookie : #{cookie}, // enable cookies to allow the server to access the session
                xfbml  : #{xfbml}  // parse XFBML
              });
              #{extra_js}
            };

            (function() {
              var s = document.createElement('div'); 
              s.setAttribute('id','fb-root'); 
              document.documentElement.getElementsByTagName("body")[0].appendChild(s);
              var e = document.createElement('script');
              e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
              e.async = true;
              s.appendChild(e);
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
