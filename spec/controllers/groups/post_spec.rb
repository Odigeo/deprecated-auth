require 'spec_helper'

describe GroupsController do
  
  render_views
  
  describe "POST" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "incredibly-fake!"
      @args = build(:group).attributes
    end
  
    
    it "should render the object partial" do
      post :create, @args      
      response.should render_template(partial: '_group', count: 1)
    end
    
    it "should return JSON" do
      post :create, @args
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      post :create, @args
      response.status.should == 400
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.headers['X-API-Token'] = 'unknown, matey'
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      post :create, @args
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield POST authorisation for Groups" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      post :create, @args
      response.status.should == 403
      response.content_type.should == "application/json"
    end

    it "should return a 422 if the Group already exists" do
      post :create, @args
      response.status.should == 201
      response.content_type.should == "application/json"
      post :create, @args
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["Group already exists"]}
    end

    #
    # Uncomment this test as soon as there is one or more DB attributes that need
    # validating.
    #
    # it "should return a 422 when there are validation errors" do
    #   post :create, @args.merge(:locale => "nix-DORF")
    #   response.status.should == 422
    #   response.content_type.should == "application/json"
    #   JSON.parse(response.body).should == {"locale"=>["ISO language code format required ('de-AU')"]}
    # end
                
    it "should return a 201 when successful" do
      post :create, @args
      response.status.should == 201
    end

    it "should contain a Location header when successful" do
      post :create, @args
      response.headers['Location'].should be_a String
    end

    it "should return the new resource in the body when successful" do
      post :create, @args
      response.body.should be_a String
    end
    
  end
  
end
