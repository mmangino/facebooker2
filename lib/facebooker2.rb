# Facebooker2
module Facebooker2
  
  class << self
    attr_accessor :api_key, :secret, :app_id
  end

end

require "mogli"

require "facebooker2/rails/controller"
require "facebooker2/rails/helpers/facebook_connect"