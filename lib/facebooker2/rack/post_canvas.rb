# Rack middleware that converts POST requests from Facebook to GET request.
# When there is a signed_parameter in the request params, this is a request iniated by the top Facebook frame
# It will be sent as a POST request that we want to convert to a GET request to keep the app restful
# See for details : http://blog.coderubik.com/?p=178
module Rack
  class PostCanvas
    
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Request.new(env)
      
      if request.POST['signed_request']
        env["REQUEST_METHOD"] = 'GET'
      end
      
      return @app.call(env)
    end
  
  end
end