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
      end
    end
  end
end