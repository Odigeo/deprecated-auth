require 'spec_helper'

describe AuthenticationsController do
    
  render_views

  describe "INDEX" do
    
    before :each do
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @auth = create :authentication
      @auth.expired?.should == false
      @joe = create :api_user, username: "joe"
      @sarah = create :api_user, username: "sarah"
      create :authentication, api_user: @joe
      create :authentication, api_user: @joe
      create :authentication, api_user: @joe
      create :authentication, api_user: @sarah
      create :authentication, api_user: @sarah
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
    end
    

    it "should render the object partial" do
      get :index
      response.should render_template(partial: '_authentication', count: 6)
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

    it "should accept a search parameter" do
      Authentication.should_receive(:index).with(anything, nil, @auth.token).and_return(Authentication.all)
      get :index, search: @auth.token
      response.status.should == 200
    end
    
    it "should accept a group parameter" do
      Authentication.should_receive(:index).with(anything, 'token', nil).and_return(Authentication.all)
      get :index, group: :token
      response.status.should == 200
    end
    
  end
  
end
