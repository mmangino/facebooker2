module Facebooker2
  module Rails
    module Helpers
      module Javascript
        def fb_connect_async_js(app_id=Facebooker2.app_id,options={})
          opts = Hash.new(true).merge!(options)
          cookie = opts[:cookie]
          status = opts[:status]
          xfbml = opts[:xfbml]
          js = <<-JAVASCRIPT
          <div id="fb-root"></div>
          <script>
            window.fbAsyncInit = function() {
              FB.init({
                appId  : '#{app_id}',
                status : #{status}, // check login status
                cookie : #{cookie}, // enable cookies to allow the server to access the session
                xfbml  : #{xfbml}  // parse XFBML
              });
            };

            (function() {
              var e = document.createElement('script');
              e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
              e.async = true;
              document.getElementById('fb-root').appendChild(e);
            }());
          </script>
        JAVASCRIPT
        end
      end
    end
  end
end