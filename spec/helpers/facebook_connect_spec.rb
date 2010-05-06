require "spec_helper"
describe Facebooker2::Rails::Helpers::FacebookConnect, :type=>:helper do
  include Facebooker2::Rails::Helpers
  describe "fb_login_and_redirect" do
    it "renders a login button" do
      fb_login_and_redirect("/").should == 
        "<fb:login-button onlogin=\"window.location.href = &quot;/&quot;;\"></fb:login-button>"
    end
    
    it "allows you to specify the text of the button" do
      fb_login_and_redirect("/",:text=>"my test").should == 
        "<fb:login-button onlogin=\"window.location.href = &quot;/&quot;;\">my test</fb:login-button>"      
    end
    
    it "allows you to specify the permissions" do
      fb_login_and_redirect("/",:perms=>"email,offline_access").should == 
        "<fb:login-button onlogin=\"window.location.href = &quot;/&quot;;\" perms=\"email,offline_access\"></fb:login-button>"      
    end
  end
  
  describe "Logging out" do
    it "has an fb_logout_link" do
      fb_logout_link("logout","/").should == 
        "<a href=\"#\" onclick=\"FB.logout(function() {window.location.href = '/';}); return false;\">logout</a>"
    end
  end
  
  describe "server FBML" do
    it "renders the yielded content inside of an fbml block" do
      fb_server_fbml do
        
      end
      output_buffer.should == "<fb:serverFbml><script type='text/fbml'></script></fb:serverFbml>"
    end
    
    it "includes the content inside the block" do
      fb_server_fbml do
        "inner text"
      end
      output_buffer.should == "<fb:serverFbml><script type='text/fbml'>inner text</script></fb:serverFbml>"      
    end
    
    it "allows specifying style attributes" do
      fb_server_fbml "width: 750px;" do
        
      end
      output_buffer.should == "<fb:serverFbml style=\"width: 750px;\"><script type='text/fbml'></script></fb:serverFbml>"
      
    end
  end
  
end

