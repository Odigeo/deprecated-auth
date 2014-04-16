require 'spec_helper'

describe ApiUsersController do

  render_views
  
  describe "GET api_users/1/authentications" do
    
    before :each do
      Authentication.destroy_all
      permit_with 200
      @it = create :api_user
      create(:authentication, username: @it.username, expires_at: 1.week.ago.utc)
      create(:authentication, username: @it.username, expires_at: 1.hour.from_now.utc)
      create(:authentication, username: @it.username, expires_at: 1.year.from_now.utc)
      create(:authentication, username: 'irrelevant')
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
        
    
    it "should render the object partial" do
      get :authentications, id: @it
      response.should render_template(partial: '_authentication', count: 3)
    end
    
    it "should return JSON" do
      get :authentications, id: @it
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :authentications, id: @it
      response.status.should == 400
      response.content_type.should == "application/json"
    end
                
    it "should return a 200 when successful" do
      get :authentications, id: @it
      response.status.should == 200
    end
    
    it "should return a collection" do
      get :authentications, id: @it
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
