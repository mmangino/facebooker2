require "spec_helper"

class FakeController < ActionController::Base
  include Facebooker2::Rails::Controller
end

describe Facebooker2::Rails::Controller do
  before(:each) do
    Facebooker2.app_id = "12345"
    Facebooker2.secret = "42ca6de519d53f6e0420247a4d108d90"
  end
  
  let :controller do
    controller = FakeController.new
    controller.stub!(:params).and_return({})
    controller.stub!(:cookies).and_return("fbs_12345"=>"\"access_token=114355055262088|57f0206b01ad48bf84ac86f1-12451752|63WyZjRQbzowpN8ibdIfrsg80OA.&expires=0&secret=1e3375dcc4527e7ead0f82c095421690&session_key=57f0206b01ad48bf84ac86f1-12451752&sig=4337fcdee4cc68bb70ec495c0eebf89c&uid=12451752\"")
    controller
  end
  
  
  it "should include helpers" do
    controller.master_helper_module.ancestors.should include(Facebooker2::Rails::Helpers)
  end
  
  describe "Cookie handling" do
    
    it "knows if a cookie exists for this app" do
      controller.fb_cookie_for_app_id?(12345).should be_true
    end
    
    it "knows when there isn't a cookie" do
      controller.fb_cookie_for_app_id?(432432).should be_false      
    end
    
    it "gets the hash from the cookie" do
      controller.stub!(:cookies).and_return("fbs_12345"=>"param1=val1&param2=val2")
      controller.fb_cookie_hash_for_app_id(12345).should == {"param1"=>"val1", "param2"=>"val2"}
    end
    
    it "creates a user from the cookie" do
      controller.current_facebook_user.should_not be_nil
      controller.current_facebook_user.should be_an_instance_of(Mogli::User)
      controller.current_facebook_user.id.should == "12451752"      
    end
    
    it "sets the client for the user" do
      controller.current_facebook_user.client.access_token.should == "114355055262088|57f0206b01ad48bf84ac86f1-12451752|63WyZjRQbzowpN8ibdIfrsg80OA."
    end
    
    it "doesn't create a user if there is no app cookie" do
      Facebooker2.app_id="other_app"
      controller.current_facebook_user.should be_nil
    end
    
    it "creates a client from the cookie" do
      controller.current_facebook_client.should_not be_nil
      controller.current_facebook_client.should be_an_instance_of(Mogli::Client)
      controller.current_facebook_client.access_token.should == "114355055262088|57f0206b01ad48bf84ac86f1-12451752|63WyZjRQbzowpN8ibdIfrsg80OA."
    end
    
    it "creates a client from params" do
      controller.stub!(:cookies).and_return({})
      controller.stub!(:facebook_params).and_return(
        :oauth_token => "103188716396725|2.N0kBq5D0cbwjTGm9J4xRgA__.3600.1279814400-585612657|Txwy8S7sWBIJnyAXebEgSx6ntgY.",
        :expires=>"1279814400",
        :user_id => "585612657")
      controller.current_facebook_client.access_token.should == "103188716396725|2.N0kBq5D0cbwjTGm9J4xRgA__.3600.1279814400-585612657|Txwy8S7sWBIJnyAXebEgSx6ntgY."
      controller.current_facebook_user.id.should == "585612657"
    end
    
    it "verifies that the signature is correct" do
      controller.fb_cookie_signature_correct?({
        "access_token"      =>  "114355055262088|57f0206b01ad48bf84ac86f1-12451752|63WyZjRQbzowpN8ibdIfrsg80OA.",
        "expires"           =>  "0",
        "secret"            =>  "1e3375dcc4527e7ead0f82c095421690",
        "session_key"       =>  "57f0206b01ad48bf84ac86f1-12451752",
        "uid"               =>  "12451752",
        "sig"               =>  "4337fcdee4cc68bb70ec495c0eebf89c"},
        "42ca6de519d53f6e0420247a4d108d90"
        ).should be_true
    end
    
    it "returns false if the signature is not correct" do
      controller.fb_cookie_signature_correct?({
        "access_token"      =>  "114355055262088|57f0206b01ad48bf84ac86f1-12451752|63WyZjRQbzowpN8ibdIfrsg80OA.",
        "expires"           =>  "0",
        "secret"            =>  "1e3375dcc4527e7ead0f82c095421690",
        "session_key"       =>  "57f0206b01ad48bf84ac86f1-12451752",
        "uid"               =>  "5436785463785",
        "sig"               =>  "4337fcdee4cc68bb70ec495c0eebf89c"},
        "42ca6de519d53f6e0420247a4d108d90"
        ).should be_false
      
    end
    
    
  end
  
  describe "Signed Request handling" do
    it "should correctly parse JSON that is poorly encoded" do
      controller.fb_signed_request_json("eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyNzk4MTQ0MDAsIm9hdXRoX3Rva2VuIjoiMTAzMTg4NzE2Mzk2NzI1fDIuTjBrQnE1RDBjYndqVEdtOUo0eFJnQV9fLjM2MDAuMTI3OTgxNDQwMC01ODU2MTI2NTd8VHh3eThTN3NXQklKbnlBWGViRWdTeDZudGdZLiIsInVzZXJfaWQiOiI1ODU2MTI2NTcifQ").
        should == "{\"algorithm\":\"HMAC-SHA256\",\"expires\":1279814400,\"oauth_token\":\"103188716396725|2.N0kBq5D0cbwjTGm9J4xRgA__.3600.1279814400-585612657|Txwy8S7sWBIJnyAXebEgSx6ntgY.\",\"user_id\":\"585612657\"}"
    end
    
    it "provides facebook_params if the sig is valid" do
      Facebooker2.secret = "mysecretkey"
      controller.stub!(:params).and_return(:signed_request=>"N1JJFILX63MufS1zpHZwN109VK1ggzEsD0N4pH-yPtc.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyNzk4MjE2MDAsIm9hdXRoX3Rva2VuIjoiMTAzMTg4NzE2Mzk2NzI1fDIucnJRSktyRzFRYXpGYTFoa2Z6MWpMZ19fLjM2MDAuMTI3OTgyMTYwMC01MzI4Mjg4Njh8TWF4QVdxTWtVS3lKbEFwOVgwZldGWEF0M004LiIsInVzZXJfaWQiOiI1MzI4Mjg4NjgifQ")
      controller.facebook_params[:user_id].should == "532828868"
    end
    
    it "doesn't provide facebook params if the sig is invalid" do
      Facebooker2.secret = "mysecretkey"
      controller.stub!(:params).and_return(:signed_request=>"invalid.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyNzk4MjE2MDAsIm9hdXRoX3Rva2VuIjoiMTAzMTg4NzE2Mzk2NzI1fDIucnJRSktyRzFRYXpGYTFoa2Z6MWpMZ19fLjM2MDAuMTI3OTgyMTYwMC01MzI4Mjg4Njh8TWF4QVdxTWtVS3lKbEFwOVgwZldGWEF0M004LiIsInVzZXJfaWQiOiI1MzI4Mjg4NjgifQ")
      controller.facebook_params.should be_blank
      
    end
  end
  
  describe "Methods" do
    
    it "allows you to sign in a user" do
      controller.fb_sign_in_user_and_client(Mogli::User.new,Mogli::Client.new)
    end
    it "has a current_facebook_user" do
      user = mock("user",:client= => nil)
      controller.fb_sign_in_user_and_client(user,Mogli::Client.new)
      controller.current_facebook_user.should == user
    end
    
    it "has a current_facebook_client" do
      client = mock("client")
      controller.fb_sign_in_user_and_client(Mogli::User.new,client)
      controller.current_facebook_client.should == client
    end
    
  end
  
end