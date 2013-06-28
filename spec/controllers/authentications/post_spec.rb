require 'spec_helper'

describe AuthenticationsController do
  
  render_views
    
  describe "POST" do
    
    before :each do
      request.headers['HTTP_ACCEPT'] = "application/json"
    end


    it "should return JSON" do
      post :create
      response.content_type.should == "application/json"
    end
    
    it "must return 400 if no X-API-Authenticate header was provided" do
      post :create
      response.content_type.should == "application/json"
      response.status.should == 400
    end
    
    it "must return 403 if the X-API-Authenticate user is unknown" do
      request.headers['X-API-Authenticate'] = ::Base64.strict_encode64("nonexistentuser:somepassword")
      post :create
      response.content_type.should == "application/json"
      response.status.should == 403
    end
    
    it "must return 403 if the X-API-Authenticate credentials don't match" do
      create :api_user, username: "myuser", password: "mypassword"
      request.headers['X-API-Authenticate'] = ::Base64.strict_encode64("myuser:wrong")
      post :create
      response.content_type.should == "application/json"
      response.status.should == 403
    end
    
    it "must return a 201 if the X-API-Authenticate credentials match" do
      create :api_user, username: "myuser", password: "mypassword"
      request.headers['X-API-Authenticate'] = ::Base64.strict_encode64("myuser:mypassword")
      post :create
      response.content_type.should == "application/json"
      response.status.should == 201
    end
    
    it "should return a complete resource when successful" do
      create :api_user, username: "myuser", password: "mypassword"
      request.headers['X-API-Authenticate'] = ::Base64.strict_encode64("myuser:mypassword")
      post :create
      response.should render_template(partial: '_authentication', count: 1)
      response.content_type.should == "application/json"
      response.status.should == 201
      response.headers['Location'].should be_blank
      r = JSON.parse(response.body)
      r.should be_a Hash   # The structural tests are done in the view specs
    end
    
    it "should not require an X-API-Token header" do
      create :api_user, username: "myuser", password: "mypassword"
      request.headers['X-API-Authenticate'] = ::Base64.strict_encode64("myuser:mypassword")
      request.headers['X-API-Token'] = nil
      post :create
      response.content_type.should == "application/json"
      response.status.should == 201
    end
    
  end
  
end
