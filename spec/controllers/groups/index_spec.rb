require 'spec_helper'

describe GroupsController do
  
  render_views

  describe "INDEX" do
    
    before :each do
      permit_with 200
      create :group
      create :group
      create :group
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
   
    
    it "should render the object partial" do
      get :index
      response.should render_template(partial: '_group', count: 3)
    end
    
    it "should return JSON" do
      get :index
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :index
      response.status.should == 400
      response.content_type.should == "application/json"
    end
            
    it "should return a 200 when successful" do
      get :index
      response.status.should == 200
    end

    it "should return a collection" do
      get :index
      response.status.should == 200
      JSON.parse(response.body).should be_an Array
    end
    
  end
  
end
