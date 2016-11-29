module Facebooker2
  module Rails
    module Helpers
      module FacebookConnect 
        #
        # Render an <fb:login-button> element, similar to
        # fb_login_button. Adds a js redirect to the onlogin event via rjs.
        #
        # ==== Examples
        #
        #   fb_login_and_redirect '/other_page'
        #   => <fb:login-button onlogin="window.location.href = &quot;/other_page&quot;;"></fb:login-button>
        #
        # Like #fb_login_button, this also supports the :text option
        #
        #   fb_login_and_redirect '/other_page', :text => "Login with Facebook", :v => '2'
        #   => <fb:login-button onlogin="window.location.href = &quot;/other_page&quot;;" v="2">Login with Facebook</fb:login-button>
        #
        def fb_login_and_redirect(url, options = {})
          # Check if we got the update_page method (pre-Rails 3.1)
          if respond_to? 'update_page'
            js = update_page do |page|
              page.redirect_to url
            end
          # Else use plain js
          else
            js = "window.location.href = '#{url}';"
          end
          text = options.delete(:text)
          
          #rails 3 only escapes non-html_safe strings, so get the raw string instead of the SafeBuffer
          content_tag("fb:login-button",text,options.merge(:onlogin=>js.to_str))
        end
        
        def fb_login(options = {},&proc)
           js = capture(&proc)
           text = options.delete(:text)
           content_tag("fb:login-button",text,options.merge(:onlogin=>js.to_str))
        end
        
        #
        # Logs the user out of facebook and redirects to the given URL
        #  args are passed to the call to link_to_function
        def fb_logout_link(text,url,*args)
          function= "FB.logout(function() {window.location.href = '#{url}';})"
          link_to_function text, function.to_str, *args
        end
        
        def fb_server_fbml(style=nil, width=nil, &proc)
          style_string=" style=\"#{style}\"" if style
          width_string=" width=\"#{width}\"" if width
          content = capture(&proc)
          output = "<fb:serverFbml#{style_string}#{width_string}><script type='text/fbml'><fb:fbml>#{content}</fb:fbml></script></fb:serverFbml>"
          output = output.respond_to?(:html_safe) ? output.html_safe : output
          concat(output)
        end
      end
    end
  end
end