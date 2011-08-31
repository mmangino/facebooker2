require "spec_helper"
describe Facebooker2::Rails::Helpers::Javascript, :type=>:helper do
  include Facebooker2::Rails::Helpers
  include Facebooker2
  describe "fb_connect_async_js" do
    context "loading with defaults" do
      it "specifies correct appId" do
        js = fb_connect_async_js '12345'
        js.include?("appId  : '12345',").should be_true, js
      end
      it "enables status" do
        js = fb_connect_async_js '12345'
        js.include?("status : true,").should be_true, js
      end
      it "enables cookies" do
        js = fb_connect_async_js '12345'
        js.include?("cookie : true,").should be_true, js
      end
      it "enables xfbml" do
        js = fb_connect_async_js '12345'
        js.include?("xfbml  : true").should be_true, js
      end
      it "does not specify a channelUrl" do
        js = fb_connect_async_js '12345'
        js.include?("channelUrl").should be_false, js
      end
      it "does not specify oauth2" do
        js = fb_connect_async_js '12345'
        js.include?("oauth2").should be_false, js
      end
      it "does select en_US" do
        js = fb_connect_async_js '12345'
        js.include?("en_US").should be_true, js
      end

      it "should be properly formed" do
        js = fb_connect_async_js '12345'
        js.should be_lintable
      end
    end


    it "disables cookies" do
      js = fb_connect_async_js '12345', :cookie => false
      js.include?("cookie : false").should be_true, js
    end
    
    it "disables checking login status" do
      js = fb_connect_async_js '12345', :status => false
      js.include?("status : false").should be_true, js
    end
    
    it "disables xfbml parsing" do
      js = fb_connect_async_js '12345', :xfbml => false
      js.include?("xfbml  : false").should be_true, js
    end
    
    it "adds a channel url" do
      js = fb_connect_async_js '12345', :channel_url => 'http://channel.url'
      js.include?("channelUrl : 'http://channel.url'").should be_true, js
    end
    
    it "changes the default locale" do
      js = fb_connect_async_js '12345', :locale => 'fr_FR'
      js.include?("//connect.facebook.net/fr_FR/all.js").should be_true, js
    end

    context "Oauth2" do
      after(:all) do
        Facebooker2.oauth2=false
      end
      it "enables oauth" do
        Facebooker2.oauth2=true
        js = fb_connect_async_js '12345'
        js.include?("oauth").should be_true, js
      end
    end

    # Can't get this to work!
    # it "adds extra js" do
    #   helper.output_buffer = ""
    #   fb_connect_async_js do
    #     "FB.Canvas.setAutoResize();"
    #   end
    #   helper.output_buffer.include?("FB.Canvas.setAutoResize();").should be_true, helper.output_buffer
    # end
    
  end
end