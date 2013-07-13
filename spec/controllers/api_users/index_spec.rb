require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "INDEX" do
    
    before :each do
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      u1 = create :api_user, username: "maggie_thatcher"
      u2 = create :api_user, username: "ronald_reagan"
      u3 = create :api_user, username: "carl_bildt"
      @auth = create :authentication, api_user: u1
      @auth.expired?.should == false
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
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
      request.headers['X-API-Token'] = nil
      get :index
      response.status.should == 400
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
