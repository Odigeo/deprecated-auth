require 'spec_helper'

describe RolesController do
  
  render_views

  describe "GET roles/1/rights" do
    
    before :each do
      permit_with 200
      @it = create :role
      r1 = create :right
      r2 = create :right
      r3 = create :right
      @it.rights << r1
      @it.rights << r2
      @it.rights << r3
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
      wrapper = JSON.parse(response.body)
      wrapper.should be_a Hash
      resource = wrapper['_collection']
      resource.should be_a Hash
      coll = resource['resources']
      coll.should be_an Array
      coll.count.should == 3
      n = resource['count']
      n.should == 3
    end

  end
  
end
