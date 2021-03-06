require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "GET" do
    
    before :each do
      permit_with 200
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
