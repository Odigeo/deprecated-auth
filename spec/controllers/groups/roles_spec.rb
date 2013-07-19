require 'spec_helper'

describe GroupsController do
  
  render_views

  describe "GET groups/1/roles" do
    
    before :each do
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @it = create :group
      @it.roles << create(:role)
      @it.roles << create(:role)
      @it.roles << create(:role)
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
    
    
    it "should render the object partial" do
      get :roles, id: @it
      response.should render_template(partial: 'roles/_role', count: 3)
    end

    it "should return JSON" do
      get :roles, id: @it
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :roles, id: @it
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :roles, id: @it
      response.status.should == 200
    end

    it "should return a collection" do
      get :roles, id: @it
      response.status.should == 200
      JSON.parse(response.body).should be_an Array
    end

  end
  
end
