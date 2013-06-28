require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "GET" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @auth = create :authentication
      @auth.expired?.should == false
      @api_user = create :api_user
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
    end


    it "should render the object partial" do
      get :show, id: @api_user
      response.should render_template(partial: '_api_user', count: 1)
    end
    
    it "should return JSON" do
      get :show, id: @api_user
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :show, id: @api_user
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.headers['X-API-Token'] = 'unknown, matey'
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :show, id: @api_user
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 400 if the authentication represented by the X-API-Token has expired" do
      @auth = create :authentication, created_at: 1.year.ago.utc, expires_at: 1.year.ago.utc
      @auth.expired?.should == true
      request.headers['X-API-Token'] = @auth.token
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :show, id: @api_user
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield GET authorisation for ApiUsers" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      get :show, id: @api_user
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 404 when the user can't be found" do
      get :show, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :show, id: @api_user
      response.status.should == 200
    end
    
  end
  
end
