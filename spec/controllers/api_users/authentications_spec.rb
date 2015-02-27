require 'spec_helper'

describe ApiUsersController do

  render_views
  
  describe "GET api_users/1/authentications" do
    
    before :each do
      Authentication.destroy_all
      permit_with 200
      @it = create :api_user
      create(:authentication, username: @it.username, expires_at: 1.week.ago.utc)       # Expired
      create(:authentication, username: @it.username, expires_at: 1.hour.from_now.utc)  # Valid
      create(:authentication, username: @it.username, expires_at: 1.year.from_now.utc)  # Valid
      create(:authentication, username: 'irrelevant')
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
        
    
    it "should render the object partial" do
      get :authentications, id: @it
      expect(response).to render_template(partial: '_authentication', count: 2)
    end
    
    it "should return JSON" do
      get :authentications, id: @it
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :authentications, id: @it
      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
    end
                
    it "should return a 200 when successful" do
      get :authentications, id: @it
      expect(response.status).to eq(200)
    end
    
    it "should return a collection" do
      get :authentications, id: @it
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
