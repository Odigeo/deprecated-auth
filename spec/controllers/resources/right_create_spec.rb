require 'spec_helper'

describe ResourcesController do
  
  render_views
  
  describe "POST" do
    
    before :each do
      permit_with 200
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "incredibly-fake!"
      ri = build(:right)
      @resource = ri.resource
      @args = {id: @resource, name: ri.name, description: ri.description,
               hyperlink: ri.hyperlink, verb: ri.verb, app: ri.app, context: ri.context}
    end
    
    
    it "should render the object partial" do
      post :right_create, @args
      expect(response).to render_template(partial: 'rights/_right')
    end

    it "should return JSON" do
      post :right_create, @args
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      post :right_create, @args
      expect(response.status).to eq(400)
    end
    
    it "should return a 422 if the right already exists" do
      post :right_create, @args
      expect(response.status).to eq(201)
      expect(response.content_type).to eq("application/json")
      post :right_create, @args
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq({"_api_error" => ["Resource not unique"]})
    end

    it "should return a 422 when there are validation errors" do
      post :right_create, @args.merge(:verb => "HEAD")
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq({"verb"=>["must be one of *, POST, GET, GET*, PUT, DELETE, or DELETE*"]})
    end
                
    it "should return a 201 when successful" do
      post :right_create, @args
      expect(response).to render_template(partial: 'rights/_right', count: 1)
      expect(response.status).to eq(201)
    end

    it "should contain a Location header when successful" do
      post :right_create, @args
      expect(response.headers['Location']).to be_a String
    end

    it "should return the new resource in the body when successful" do
      post :right_create, @args
      expect(response.body).to be_a String
    end

    it "should increase the number of associated Rights for the Resource by one" do
      expect(@resource.rights.count).to eq(0)
      post :right_create, @args
      expect(@resource.rights.count).to eq(1)
    end
    
  end
  
end