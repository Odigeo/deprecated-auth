require 'spec_helper'

describe GroupsController do
  
  render_views

  describe "GET groups/1/api_users" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @it = create :group
      u1 = create :api_user
      u2 = create :api_user
      u3 = create :api_user
      @it.api_users << u1
      @it.api_users << u2
      @it.api_users << u3
      request.env['HTTP_ACCEPT'] = "application/json"
      request.env['X-API-Token'] = "boy-is-this-fake"
    end
        
    
    it "should render the object partial" do
      get :api_users, id: @it
      response.should render_template(partial: 'api_users/_api_user', count: 3)
    end
    
    it "should return JSON" do
      get :api_users, id: @it
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.env['X-API-Token'] = nil
      get :api_users, id: @it
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.env['X-API-Token'] = 'unknown, matey'
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :api_users, id: @it
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 403 if the X-API-Token doesn't yield GET authorisation" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      get :api_users, id: @it
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 200 when successful" do
      get :api_users, id: @it
      response.status.should == 200
    end

  end
  
end
