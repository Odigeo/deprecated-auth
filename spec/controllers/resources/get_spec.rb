require 'spec_helper'

describe ResourcesController do
  
  render_views

  describe "GET" do
    
    before :each do
      permit_with 200
      @resource = create :resource
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "totally-fake"
    end

    
    it "should return JSON" do
      get :show, id: @resource
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :show, id: @resource
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 404 when the user can't be found" do
      get :show, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :show, id: @resource
      response.should render_template(partial: '_resource', count: 1)
      response.status.should == 200
    end
    
  end
  
end
