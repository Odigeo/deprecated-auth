require 'spec_helper'

describe RolesController do
  
  render_views

  describe "GET roles/1/groups" do
    
    before :each do
      permit_with 200
      @it = create :role
      g1 = create :group
      g2 = create :group
      g3 = create :group
      @it.groups << g1
      @it.groups << g2
      @it.groups << g3
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
    
    
    it "should return JSON" do
      get :groups, id: @it
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :groups, id: @it
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :groups, id: @it
      response.should render_template(partial: 'groups/_group', count: 3)
      response.status.should == 200
    end
    
    it "should return a collection" do
      get :groups, id: @it
      response.status.should == 200
      JSON.parse(response.body).should be_an Array
    end

  end
  
end
