require 'spec_helper'

describe ServicesController do
  
  render_views

  describe "GET resources" do
    
    before :each do
      permit_with 200
      @s1 = create :service
      @r1 = create :resource, service: @s1
      @r2 = create :resource, service: @s1
      @s2 = create :service
      @r3 = create :resource, service: @s2
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
    
    
    it "should return JSON" do
      get :resources, id: @s1
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :resources, id: @s1
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :resources, id: @s1
      response.should render_template(partial: "resources/_resource", count: 2)
      response.status.should == 200
    end
    
    it "should return a collection" do
      get :resources, id: @s1
      response.status.should == 200
      wrapper = JSON.parse(response.body)
      wrapper.should be_a Hash
      resource = wrapper['_collection']
      resource.should be_a Hash
      coll = resource['resources']
      coll.should be_an Array
      coll.count.should == 2
      n = resource['count']
      n.should == 2
    end

  end
  
end
