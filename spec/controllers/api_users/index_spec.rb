require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "INDEX" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      u1 = create :api_user, username: "maggie_thatcher"
      u2 = create :api_user, username: "ronald_reagan"
      u3 = create :api_user, username: "carl_bildt"
      @auth = create :authentication, api_user: u1
      @auth.expired?.should == false
      request.env['HTTP_ACCEPT'] = "application/json"
      request.env['X-API-Token'] = @auth.token
    end

    
    it "should render the object partial" do
      get :index
      response.should render_template(partial: '_api_user', count: 3)
    end
    
    it "should return JSON" do
      get :index
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.env['X-API-Token'] = nil
      get :index
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.env['X-API-Token'] = 'unknown, matey'
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :index
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token has expired" do
      @auth = create :authentication, created_at: 1.year.ago.utc, expires_at: 1.year.ago.utc
      @auth.expired?.should == true
      request.env['X-API-Token'] = @auth.token
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :index
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 403 if the X-API-Token doesn't yield GET authorisation for ApiUsers" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      get :index
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 200 when successful" do
      get :index
      response.status.should == 200
    end
    
    it "should accept a search parameter" do
      ApiUser.should_receive(:index).with(a_kind_of(Hash), nil, 'reagan').and_return([])
      get :index, search: 'reagan'
      response.status.should == 200
    end
    
    it "should accept a group parameter" do
      ApiUser.should_receive(:index).with(anything, 'context', nil).and_return([])
      get :index, app: 'foo', group: :context
      response.status.should == 200
    end
  end
  
end
