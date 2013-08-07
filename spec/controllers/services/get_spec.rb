require 'spec_helper'

describe ServicesController do
  
  render_views

  describe "GET" do
    
    before :each do
      permit_with 200
      @service = create :service
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "totally-fake"
    end
    
    
    it "should return JSON" do
      get :show, id: @service
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :show, id: @service
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 404 when the user can't be found" do
      get :show, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :show, id: @service
      response.should render_template(partial: "_service", count: 1)
      response.status.should == 200
    end
    
  end
  
end
