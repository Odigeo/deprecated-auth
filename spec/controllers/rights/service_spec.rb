require 'spec_helper'

describe RightsController do
  
  render_views

  describe "GET rights/1/service" do
    
    before :each do
      permit_with 200
      @right = create :right
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "totally-fake"
    end
    
    
    it "should render the object partial" do
      get :service, id: @right
      response.should render_template(partial: 'services/_service', count: 1)
    end
    
    it "should return JSON" do
      get :service, id: @right
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :service, id: @right
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 404 when the user can't be found" do
      get :service, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :service, id: @right
      response.status.should == 200
    end
    
  end
  
end
