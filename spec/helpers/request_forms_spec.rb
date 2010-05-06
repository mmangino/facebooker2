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
  
  describe "request form" do
     it "includes the name, url, and a message" do
       fb_request_form "Title","URL","message" do
       end
       @output_buffer.should == "<fb:request-form action=\"URL\" content=\"message\" invite=\"true\" method=\"post\" type=\"Title\"></fb:request-form>"
       
     end
     
     it "renders the yielded content" do
       fb_request_form "Title","URL","message" do
         "yielded"
       end
       @output_buffer.should =~ /yielded/
     end
     
     it "allows you to override params" do
       fb_request_form "Title","URL","message",:invite=>false do
       end
       @output_buffer.should =~ /invite="false"/
       
     end
     
     
  end
  
  
end