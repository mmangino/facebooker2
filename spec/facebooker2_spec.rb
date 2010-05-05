require "spec_helper"
describe Facebooker2 do
  
  describe "Configuration" do
    it "allows setting of the api_key" do
      Facebooker2.api_key = "123456"
      Facebooker2.api_key.should == "123456"
    end
    
    it "allows setting of the secret" do
      Facebooker2.secret = "mysecret"
      Facebooker2.secret.should == "mysecret"
    end
    
    it "has an app_id" do
      Facebooker2.app_id = "12345"
      Facebooker2.app_id.should == "12345"      
    end
  end
  
  describe "Casting to facebook_id" do
    it "grabs the id from Mogli::User objects" do
      Facebooker2.cast_to_facebook_id(Mogli::User.new(:id=>1234)).should == 1234
    end
    
    it "checks for facebook_id and calls that" do
      Facebooker2.cast_to_facebook_id(mock("name",:facebook_id=>1234)).should == 1234
    end
    
    it "returns the passed object otherwise" do
      Facebooker2.cast_to_facebook_id("1234").should == "1234"
    end
  end
end