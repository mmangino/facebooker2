module Facebooker2
  module Rails
    module Helpers
      module RequestForms
        def fb_req_choice(label,url)
          tag "fb:req-choice",:label=>label,:url=>url
        end
        
        def fb_multi_friend_selector(message,options={},&block)
          options = fb_stringify_vals({:showborder=>false,:actiontext=>message,:max=>20}.merge(options.dup))
          tag("fb:multi-friend-selector",options)
        end
        
        def fb_request_form(type,url,message,options={},&block)
          content = capture(&block)
          concat(content_tag("fb:request-form", content.to_s + fb_forgery_protection_token_tag,
                    {:action=>url,:method=>"post",:invite=>true,:type=>type,:content=>message}.merge(options)))
        end
        
        
        def fb_forgery_protection_token_tag
          unless protect_against_forgery?
            ''
          else
            tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
          end
        end
        
        
      end
    end
  end
end