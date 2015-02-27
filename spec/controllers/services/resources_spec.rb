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
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :resources, id: @s1
      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 200 when successful" do
      get :resources, id: @s1
      expect(response).to render_template(partial: "resources/_resource", count: 2)
      expect(response.status).to eq(200)
    end
    
    it "should return a collection" do
      get :resources, id: @s1
      expect(response.status).to eq(200)
      wrapper = JSON.parse(response.body)
      expect(wrapper).to be_a Hash
      resource = wrapper['_collection']
      expect(resource).to be_a Hash
      coll = resource['resources']
      expect(coll).to be_an Array
      expect(coll.count).to eq(2)
      n = resource['count']
      expect(n).to eq(2)
    end

  end
  
end
