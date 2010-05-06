module Facebooker2
  module Rails
    module Helpers
      include FacebookConnect
      include Javascript
      include RequestForms
      include User
      
       def fb_stringify_vals(hash)
        result={}
        hash.each do |key,value|
          result[key]=value.to_s
        end
        result
       end
        def fb_transform_keys(options,transformation_hash)
          new_hash = {}
          options.each do |key,value|
            new_key = transformation_hash[key]||key
            new_hash[new_key]=value
          end
          new_hash
        end
        FB_ALWAYS_VALID_OPTION_KEYS = [:class, :style]
      
      def fb_assert_valid_keys(options,*valid_keys)
        unknown_keys = options.keys - [valid_keys + FB_ALWAYS_VALID_OPTION_KEYS].flatten
        raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
      end    
      
    end
  end
end