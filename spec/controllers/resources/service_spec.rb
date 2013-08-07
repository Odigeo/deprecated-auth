require 'spec_helper'

describe ResourcesController do
  
  render_views

  describe "GET resources/1/service" do
    
    before :each do
      permit_with 200
      @resource = create :resource
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "totally-fake"
    end
    
    
    it "should return JSON" do
      get :service, id: @resource
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :service, id: @resource
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 404 when the resource can't be found" do
      get :service, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :service, id: @resource
      response.should render_template(partial: 'services/_service', count: 1)
      response.status.should == 200
    end
    
  end
  
end
