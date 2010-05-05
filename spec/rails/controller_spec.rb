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
    
    it "doesn't create a user if there is no app cookie" do
      Facebooker2.app_id="other_app"
      controller.current_facebook_user.should be_nil
    end
    
    it "creates a client from the cookie" do
      controller.current_facebook_client.should_not be_nil
      controller.current_facebook_client.should be_an_instance_of(Mogli::Client)
      controller.current_facebook_client.access_token.should == "114355055262088|57f0206b01ad48bf84ac86f1-12451752|63WyZjRQbzowpN8ibdIfrsg80OA."
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
  
  describe "Methods" do
    
    it "allows you to sign in a user" do
      controller.fb_sign_in_user_and_client(Mogli::User.new,Mogli::Client.new)
    end
    it "has a current_facebook_user" do
      user = mock("user")
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