require 'spec_helper'

describe ServicesController do
  
  render_views
  
  describe "POST" do
    
    before :each do
      permit_with 200
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "incredibly-fake!"
      r = build(:resource)
      @service = r.service
      @args = {id: @service, name: r.name, description: r.description}
    end

    
    it "should return JSON" do
      post :resource_create, @args
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      post :resource_create, @args
      response.status.should == 400
    end
    
    it "should return a 422 if the resource already exists" do
      post :resource_create, @args
      response.status.should == 201
      response.content_type.should == "application/json"
      post :resource_create, @args
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["Resource not unique"]}
    end

    it "should return a 422 when there are validation errors" do
      post :create, @args.merge('name' => "xxxx xxxx xxxx")
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"name"=>["is invalid"]}
    end
                
    it "should return a 201 when successful" do
      post :resource_create, @args
      response.should render_template(partial: "resources/_resource", count: 1)
      response.status.should == 201
    end

    it "should contain a Location header when successful" do
      post :resource_create, @args
      response.headers['Location'].should be_a String
    end

    it "should return the new resource in the body when successful" do
      post :resource_create, @args
      response.body.should be_a String
    end

    it "should increase the number of associated Resources for the Service by one" do
      @service.resources.count.should == 0
      post :resource_create, @args
      @service.resources.count.should == 1
    end

  end
  
end
