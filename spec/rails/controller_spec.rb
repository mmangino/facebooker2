require "spec_helper"

class FakeController < ActionController::Base
  include Facebooker2::Rails::Controller
end

describe Facebooker2::Rails::Controller do


  def compare_cookie_values(actual,expected)
    pairify_cookie(actual).should == pairify_cookie(expected)
  end

  def pairify_cookie(value)   
    value.gsub('"',"").split("&").sort
  end

  # This spec has side effects. The configuration
  # needs to be rebuilt for the following tests to pass.
  after(:all) do
    Facebooker2.app_id = "12345"
    Facebooker2.secret = "42ca6de519d53f6e0420247a4d108d90"
  end

  describe "Using oauth2" do
    let :controller do
      controller = FakeController.new
    end

    it "decodes valid base64url data" do
      # The Base64 representation of '>>>>??????' is 'Pj4+Pj8/Pz8/Pw=='
      # The FB doc http://developers.facebook.com/docs/authentication/signed_request/ references
      # http://developers.facebook.com/docs/authentication/signed_request/. The test input is a valid
      # Base64URL encoded string.
      controller.base64_url_decode('Pj4-Pj8_Pz8_Pw').should == ">>>>??????"
    end

    it "correctly decodes valid JSON payload" do
      JSON.parse(controller.base64_url_decode('eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsIjAiOiJwYXlsb2FkIn0')).should == {"algorithm"=>"HMAC-SHA256", "0" => "payload"}
    end

    context "Signed request present" do
      before do
        Facebooker2.secret='secret'
      end
      # Example from the FB Signed Request doc : http://developers.facebook.com/docs/authentication/signed_request/
      #vlXgu64BQGFSQrY0ZcJBZASMvYvTHu9GQ0YM9rjPSso.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsIjAiOiJwYXlsb2FkIn0
      it "recognizes a valid signature" do
        controller.fb_signed_request_sig_valid?('vlXgu64BQGFSQrY0ZcJBZASMvYvTHu9GQ0YM9rjPSso','eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsIjAiOiJwYXlsb2FkIn0').should be_true
      end
      it "rejects an invalid signature" do
        controller.fb_signed_request_sig_valid?('QGFSQrY0ZcJBZASMvYvTHu9GQ0YM9rjPSso','eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsIjAiOiJwYXlsb2FkIn0').should be_false
      end

    end
  end
  
end
