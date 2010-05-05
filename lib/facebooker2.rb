# Facebooker2
require "mogli"

module Facebooker2
  
  class << self
    attr_accessor :api_key, :secret, :app_id
  end
  
  def self.cast_to_facebook_id(object)
    if object.kind_of?(Mogli::Profile)
      object.id
    elsif object.respond_to?(:facebook_id)
      object.facebook_id
    else
      object
    end
  end
end


require "facebooker2/rails/controller"
require "facebooker2/rails/helpers/facebook_connect"
require "facebooker2/rails/helpers/user"
require "facebooker2/rails/helpers"