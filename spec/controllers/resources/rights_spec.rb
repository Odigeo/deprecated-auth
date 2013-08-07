require 'spec_helper'

describe ResourcesController do
  
  render_views

  describe "GET resources/1/rights" do
    
    before :each do
      permit_with 200
      @it = create :resource
      create :right, resource: @it
      create :right, resource: @it
      create :right, resource: @it
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
    
    
    it "should return JSON" do
      get :rights, id: @it
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :rights, id: @it
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :rights, id: @it
      response.should render_template(partial: 'rights/_right', count: 3)
      response.status.should == 200
    end
    
    it "should return a collection" do
      get :rights, id: @it
      response.status.should == 200
      JSON.parse(response.body).should be_an Array
    end

  end
  
end
