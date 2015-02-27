require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "GET api_users/1/rights" do
    
    before :each do
      permit_with 200
      @it = create :api_user
      @the_rights = [create(:right), create(:right), create(:right)]
      allow_any_instance_of(ApiUser).to receive(:effective_rights).and_return(@the_rights)
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
    
    
    it "should return JSON" do
      get :rights, id: @it
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :rights, id: @it
      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 200 when successful" do
      get :rights, id: @it
      expect(response.status).to eq(200)
    end
    
    it "should render the object partial" do
      get :rights, id: @it
      expect(response).to render_template(partial: 'rights/_right', count: @the_rights.length)
    end
    
    it "should return a collection" do
      get :rights, id: @it
      expect(response.status).to eq(200)
      wrapper = JSON.parse(response.body)
      expect(wrapper).to be_a Hash
      resource = wrapper['_collection']
      expect(resource).to be_a Hash
      coll = resource['resources']
      expect(coll).to be_an Array
      expect(coll.count).to eq(@the_rights.length)
      n = resource['count']
      expect(n).to eq(@the_rights.length)
    end
    
  end
  
end
