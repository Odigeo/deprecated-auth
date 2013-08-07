require 'spec_helper'

describe ApiUsersController do

  render_views
  
  describe "GET api_users/1/authentications" do
    
    before :each do
      permit_with 200
      @it = create :api_user
      @it.authentications << create(:authentication)
      @it.authentications << create(:authentication)
      @it.authentications << create(:authentication)
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
      JSON.parse(response.body).should be_an Array
    end

  end
  
end
