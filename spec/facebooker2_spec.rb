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
end