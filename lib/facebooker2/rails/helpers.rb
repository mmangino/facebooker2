module Facebooker2
  module Rails
    module Helpers
      include FacebookConnect
      include Javascript
      include User
    end
  end
end