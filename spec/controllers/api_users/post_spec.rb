require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "POST" do
    
    before :each do
      permit_with 200
      @auth = create :authentication
      expect(@auth.expired?).to eq(false)
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
    end



    it "should return JSON" do
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      expect(response.status).to eq(400)
    end
    
    it "should return a 422 if the user already exists" do
      post :create, username: "berit", password: "sub_rosa", email: "foo@example.com"
      expect(response.status).to eq(201)
      post :create, username: "berit", password: "some_other_password", email: "bar@example.com"
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq({"_api_error" => ["Resource not unique"]})
    end

    it "should return a 422 when there are validation errors" do
      post :create, username: " ", password: nil, email: "", 
                    authentication_duration: nil, 
                    shared_tokens: "not a boolean"
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq({"username" => ["can't be blank"],
                                           "password" => ["can't be blank"],
                                           "email" => ["can't be blank"],
                                           "authentication_duration" => ["can't be blank", "is not a number"]})
    end
        
    it "should return a 422 when the username is invalid" do
      post :create, username: "oh no spaces are not allowed", password: "secret", email: "x@example.com"
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq({"username"=>["is invalid"]})
    end
        
    it "should return a 201 when successful" do
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      expect(response.status).to eq(201)
    end

    it "should render the object partial when successful" do
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      expect(response).to render_template(partial: '_api_user', count: 1)
    end
    
    it "should contain a Location header when successful" do
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      expect(response.headers['Location']).to be_a String
    end

    it "should return the new resource in the body when successful" do
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com"
      expect(response.body).to be_a String
    end

    it "should not allow the indestructible flag to be set" do
      post :create, username: "berit", password: "sub_rosa", email: "berit@example.com",
                    indestructible: true
      u = JSON.parse(response.body)['api_user']
      expect(u['username']).to eq("berit")
      expect(u['indestructible']).to eq(nil)
    end
  end
  
end
