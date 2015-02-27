require 'spec_helper'

describe GroupsController do
  
  render_views

  describe "GET groups/1/roles" do
    
    before :each do
      permit_with 200
      @it = create :group
      @it.roles << create(:role)
      @it.roles << create(:role)
      @it.roles << create(:role)
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
    
    
    it "should render the object partial" do
      get :roles, id: @it
      expect(response).to render_template(partial: 'roles/_role', count: 3)
    end

    it "should return JSON" do
      get :roles, id: @it
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :roles, id: @it
      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 200 when successful" do
      get :roles, id: @it
      expect(response.status).to eq(200)
    end

    it "should return a collection" do
      get :roles, id: @it
      expect(response.status).to eq(200)
      wrapper = JSON.parse(response.body)
      expect(wrapper).to be_a Hash
      resource = wrapper['_collection']
      expect(resource).to be_a Hash
      coll = resource['resources']
      expect(coll).to be_an Array
      expect(coll.count).to eq(3)
      n = resource['count']
      expect(n).to eq(3)
    end

  end
  
end
