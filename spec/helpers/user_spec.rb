require "spec_helper"
describe Facebooker2::Rails::Helpers::User, :type=>:helper do
  include Facebooker2::Rails::Helpers
  describe "name" do
    it "has an fb_name tag" do
      fb_name("1").should == "<fb:name uid=\"1\"></fb:name>"
      
    end
    
    it "translates keys from uderscore to facebook" do
      fb_name("loggedinuser",:use_you=>true).should == "<fb:name uid=\"loggedinuser\" useyou=\"true\"></fb:name>"
    end
    
    it "raises an error on invalid keys" do
      lambda do
        fb_name("loggedinuser",:invalid=>true)
      end.should raise_error(ArgumentError)
    end
    
    it "casts the user to a facebook id" do
      fb_name(Mogli::User.new(:id=>"123")).should =~ /uid="123"/
    end
  end
  
  describe "profile pic" do
    it "has an fb_profile_pic tag" do
      fb_profile_pic("loggedinuser").should == "<fb:profile-pic uid=\"loggedinuser\"></fb:profile-pic>"
    end
    
    it "translates keys" do
      fb_profile_pic(1,:facebook_logo=>true).should == 
        "<fb:profile-pic facebook-logo=\"true\" uid=\"1\"></fb:profile-pic>"
    end
    
    it "validates the size option" do
      lambda do
        fb_profile_pic(1,:size=>:invalid)
      end.should raise_error(ArgumentError)
    end
    
    it "raises an error on invalid keys" do
      lambda do
        fb_profile_pic(1,:invalid=>true)
      end.should raise_error(ArgumentError)
    end
    
    it "casts the user to a facebook_id" do
      fb_profile_pic(Mogli::User.new(:id=>1)).should == "<fb:profile-pic uid=\"1\"></fb:profile-pic>"
      
    end
  end
end
