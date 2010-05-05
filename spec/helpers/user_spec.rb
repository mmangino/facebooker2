require "spec_helper"
describe Facebooker2::Rails::Helpers::User, :type=>:helper do
  include Facebooker2::Rails::Helpers::User
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
end
