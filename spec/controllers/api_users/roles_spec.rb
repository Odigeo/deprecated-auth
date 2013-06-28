require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "GET api_users/1/roles" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @it = create :api_user
      @it.roles << create(:role)
      @it.roles << create(:role)
      @it.roles << create(:role)
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
    
    
    it "should render the object partial" do
      get :roles, id: @it
      response.should render_template(partial: 'roles/_role', count: 3)
    end
    
    it "should return JSON" do
      get :roles, id: @it
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :roles, id: @it
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.headers['X-API-Token'] = 'unknown, matey'
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :roles, id: @it
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 403 if the X-API-Token doesn't yield GET authorisation" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      get :roles, id: @it
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 200 when successful" do
      get :roles, id: @it
      response.status.should == 200
    end
    
  end
  
end
