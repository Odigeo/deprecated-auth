require 'spec_helper'

describe GroupsController do
  
  render_views

  describe "INDEX" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
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
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.headers['X-API-Token'] = 'unknown, matey'
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :index
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 403 if the X-API-Token doesn't yield GET authorisation for Groups" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      get :index
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 200 when successful" do
      get :index
      response.status.should == 200
    end

    it "should accept match and search parameters" do
      Group.should_receive(:index).with(anything, nil, 'ue').and_return([])
      get :index, app: 'foo', search: 'ue'
      response.status.should == 200
    end
    
    it "should accept a group parameter" do
      Group.should_receive(:index).with(anything, 'context', nil).and_return([])
      get :index, app: 'foo', group: :context
      response.status.should == 200
    end
    
  end
  
end
