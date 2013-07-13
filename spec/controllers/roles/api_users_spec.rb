require 'spec_helper'

describe RolesController do
  
  render_views

  describe "GET roles/1/api_users" do
    
    before :each do
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @it = create :role
      u1 = create :api_user
      u2 = create :api_user
      u3 = create :api_user
      @it.api_users << u1
      @it.api_users << u2
      @it.api_users << u3
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
    
    
    it "should return JSON" do
      get :api_users, id: @it
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :api_users, id: @it
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :api_users, id: @it
      response.should render_template(partial: 'api_users/_api_user', count: 3)
      response.status.should == 200
    end

  end
  
end
