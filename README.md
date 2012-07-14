Facebooker2
===========

Provides rails helpers for interfacing with [Facebook's OpenGraph Javascript
API](http://developers.facebook.com/docs/reference/javascript/).

Requires the mogli and ruby-hmac gems.


Example
-------

0- Prerequisite: You need a facebook app.  Have your API Key, Application
Secret, and Application ID handy.

1- Install facebooker2 as a plugin in your rails app.

2- Create `config/facebooker.yml` with the appropriate environment.

    production:
      app_id: <your application id>
      secret: <your application secret>
      api_key: <your application key>

3- Create `config/initializers/facebooker2.rb` and place the following line in it

    Facebooker2.load_facebooker_yaml

4- Add the following line to your `app/controllers/application_controller.rb`
   (add it right after the line class `ApplicationController < ActionController::Base` so as to add the Facebooker2 instance methods to the Application controller)

    include Facebooker2::Rails::Controller

5- Update your rails applications to use the rails helpers.  This could be in a
shared login partial.

    <%= fb_connect_async_js %>
    <% if current_facebook_user %>
    <% current_facebook_user.fetch %>
      <%= "Welcome #{current_facebook_user.first_name} #{current_facebook_user.last_name}!" %>
      or 
      <%= "Hello #{fb_name(current_facebook_user, :useyou => false)}!".html_safe %>
      <%= fb_logout_link("Logout of fb", request.url) %><br />
    <% else
       # you must explicitly request permissions for facebook user fields.
       # here we instruct facebook to ask the user for permission for our website
       # to access the user's facebook email and birthday
       %>
      <%= fb_login_and_redirect('<your URL here>', :scope => 'email,user_birthday') %>
    <% end %>

Facebook canvas applications
----------------------------

If you are building an application that runs inside a Facebook canvas, all the coming requests from Facebook to your iframe will
be [POST requests](http://developers.facebook.com/docs/canvas/post/).

You can use the PostCanvas rack middleware to turn the Facebook POST requests back to GET requests and keep your app restful
as described in [this blog post](http://blog.coderubik.com/?p=178).
If you are using Rails 3, put this line of code inside your `config.ru` file :

    use Rack::PostCanvas

Also, if you plan on supporting IE 6/7 and use cookie authentication, you should add a P3P header to your response in order for IE to accept the cookie :

    before_filter :set_p3p_header_for_third_party_cookies
    
See [this blog post](http://www.softwareprojects.com/resources/programming/t-how-to-get-internet-explorer-to-use-cookies-inside-1612.html)
and [this forum thread](http://forum.developers.facebook.net/viewtopic.php?id=452) for details.

Contributing
------------

Unit tests use rspec and require the following environment configuration to run:
    rails 2.3.10
    rspec 1.3.1
    rspec-rails 1.3.3
    json 1.4.0

Invoke tests on Mac/Linux by running `rake spec` from this directory

Invoke tests on Windows by running `spec spec/` from this directory



Copyright (c) 2010 Mike Mangino, released under the MIT license
