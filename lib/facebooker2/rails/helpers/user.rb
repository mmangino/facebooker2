module Facebooker2
  module Rails
    module Helpers
      module User
        # Render an fb:name tag for the given user
        # This renders the name of the user specified.  You can use this tag as both subject and object of 
        # a sentence.  <em> See </em> http://wiki.developers.facebook.com/index.php/Fb:name for full description.  
        # Use this tag on FBML pages instead of retrieving the user's info and rendering the name explicitly.
        #
        def fb_name(user, options={})
          options = fb_transform_keys(options,FB_NAME_OPTION_KEYS_TO_TRANSFORM)
          fb_assert_valid_keys(options, FB_NAME_VALID_OPTION_KEYS)
          options.merge!(:uid => Facebooker2.cast_to_facebook_id(user))
          content_tag("fb:name",nil, fb_stringify_vals(options))
        end

        FB_NAME_OPTION_KEYS_TO_TRANSFORM = {:first_name_only => :firstnameonly, 
                                            :last_name_only => :lastnameonly,
                                            :show_network => :shownetwork,
                                            :use_you => :useyou,
                                            :if_cant_see => :ifcantsee,
                                            :subject_id => :subjectid}
        FB_NAME_VALID_OPTION_KEYS = [:firstnameonly, :linked, :lastnameonly, :possessive, :reflexive, 
                                     :shownetwork, :useyou, :ifcantsee, :capitalize, :subjectid]
        
        
        def fb_profile_pic(user, options={})
          options = options.dup
          validate_fb_profile_pic_size(options)
          options = fb_transform_keys(options,FB_PROFILE_PIC_OPTION_KEYS_TO_TRANSFORM)
          fb_assert_valid_keys(options,FB_PROFILE_PIC_VALID_OPTION_KEYS)
          options.merge!(:uid => Facebooker2.cast_to_facebook_id(user))
          content_tag("fb:profile-pic", nil,fb_stringify_vals(options))
        end

        FB_PROFILE_PIC_OPTION_KEYS_TO_TRANSFORM = {:facebook_logo => 'facebook-logo'}
        FB_PROFILE_PIC_VALID_OPTION_KEYS = [:size, :linked, 'facebook-logo', :width, :height]
        VALID_FB_PROFILE_PIC_SIZES = [:thumb, :small, :normal, :square]
        def validate_fb_profile_pic_size(options)
          if options.has_key?(:size) && !VALID_FB_PROFILE_PIC_SIZES.include?(options[:size].to_sym)
            raise(ArgumentError, "Unknown value for size: #{options[:size]}")
          end
        end

       
      end
    end
  end
end