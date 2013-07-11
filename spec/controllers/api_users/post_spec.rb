require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "POST" do
    
    before :each do
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @auth = create :authentication
      @auth.expired?.should == false
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
    end



    it "should return JSON" do
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      response.status.should == 400
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.headers['X-API-Token'] = 'unknown, matey'
      Api.stub(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 400 if the authentication represented by the X-API-Token has expired" do
      @auth = create :authentication, created_at: 1.year.ago.utc, expires_at: 1.year.ago.utc
      @auth.expired?.should == true
      request.headers['X-API-Token'] = @auth.token
      Api.stub(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 403 if the X-API-Token doesn't yield POST authorisation for ApiUsers" do
      Api.stub(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      response.status.should == 403
      response.content_type.should == "application/json"
    end

    it "should return a 422 if the user already exists" do
      post :create, username: "berit", password: "sub_rosa", email: "foo@example.com"
      response.status.should == 201
      post :create, username: "berit", password: "some_other_password", email: "bar@example.com"
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["ApiUser already exists"]}
    end

    it "should return a 422 when there are validation errors" do
      post :create, username: " ", password: nil, email: "", 
                    authentication_duration: nil, 
                    shareable_authentications: "not a boolean"
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"username" => ["can't be blank"],
                                           "password" => ["can't be blank"],
                                           "email" => ["can't be blank"],
                                           "authentication_duration" => ["can't be blank", "is not a number"]}
    end
        
    it "should return a 422 when the username is invalid" do
      post :create, username: "oh no spaces are not allowed", password: "secret", email: "x@example.com"
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"username"=>["is invalid"]}
    end
        
    it "should return a 201 when successful" do
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      response.status.should == 201
    end

    it "should render the object partial when successful" do
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      response.should render_template(partial: '_api_user', count: 1)
    end
    
    it "should contain a Location header when successful" do
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      response.headers['Location'].should be_a String
    end

    it "should return the new resource in the body when successful" do
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      response.body.should be_a String
    end
    
  end
  
end
