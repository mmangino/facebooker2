require "spec_helper"
describe Facebooker2::Rails::Helpers::RequestForms, :type=>:helper do
  include Facebooker2::Rails::Helpers
  
  it "renders a request choice" do
    fb_req_choice("mylabel","myurl").should == 
      "<fb:req-choice label=\"mylabel\" url=\"myurl\" />"
  end
  
  describe "multi friend selector" do
    it "renders a multi friend selector" do
      fb_multi_friend_selector("my message").should ==
        "<fb:multi-friend-selector actiontext=\"my message\" max=\"20\" showborder=\"false\" />"
    end
    
    it "allows you to override the default options" do
      fb_multi_friend_selector("my message",:max=>5).should =~  /max="5"/
    end
    
  end
end