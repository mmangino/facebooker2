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
    
    it "should allow setting the configuration in bulk" do
      Facebooker2.configuration = {:app_id=>1234,:secret=>"secret"}
      Facebooker2.app_id.should == 1234
      Facebooker2.secret.should == "secret"
      
    end
    
    it "raises an exception if you access a nil app_id" do
      Facebooker2.app_id = nil
      lambda do 
        Facebooker2.app_id
      end.should raise_error(Facebooker2::NotConfigured)
    end
    
    it "can load the configuration via facebooker.yml" do
      ::Rails=mock("rails",:env=>"spec",:root=>File.dirname(__FILE__))
      Facebooker2.load_facebooker_yaml
      Facebooker2.app_id.should == "1234fromyaml"
      Facebooker2.secret.should == "fromyaml"
    end
    
    it "raises an error if there is no configuration for the env" do
      ::Rails=mock("rails",:env=>"invalid",:root=>File.dirname(__FILE__))
      lambda do
        Facebooker2.load_facebooker_yaml
      end.should raise_error(Facebooker2::NotConfigured)
      
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