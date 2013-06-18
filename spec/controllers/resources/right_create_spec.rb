require 'spec_helper'

describe ResourcesController do
  
  render_views
  
  describe "POST" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      request.env['HTTP_ACCEPT'] = "application/json"
      request.env['X-API-Token'] = "incredibly-fake!"
      ri = build(:right)
      @resource = ri.resource
      @args = {id: @resource, name: ri.name, description: ri.description,
               hyperlink: ri.hyperlink, verb: ri.verb, app: ri.app, context: ri.context}
    end
    
    
    it "should render the object partial" do
      post :right_create, @args
      response.should render_template(partial: 'rights/_right')
    end

    it "should return JSON" do
      post :right_create, @args
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.env['X-API-Token'] = nil
      post :right_create, @args
      response.status.should == 400
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.env['X-API-Token'] = 'unknown, matey'
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      post :right_create, @args
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield POST authorisation for Rights" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      post :right_create, @args
      response.status.should == 403
      response.content_type.should == "application/json"
    end

    it "should return a 422 if the right already exists" do
      post :right_create, @args
      response.status.should == 201
      response.content_type.should == "application/json"
      post :right_create, @args
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["Right already exists"]}
    end

    it "should return a 422 when there are validation errors" do
      post :right_create, @args.merge(:verb => "HEAD")
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"verb"=>["must be one of *, POST, GET, GET*, PUT, or DELETE"]}
    end
                
    it "should return a 201 when successful" do
      post :right_create, @args
      response.should render_template(partial: 'rights/_right', count: 1)
      response.status.should == 201
    end

    it "should contain a Location header when successful" do
      post :right_create, @args
      response.headers['Location'].should be_a String
    end

    it "should return the new resource in the body when successful" do
      post :right_create, @args
      response.body.should be_a String
    end

    it "should increase the number of associated Rights for the Resource by one" do
      @resource.rights.count.should == 0
      post :right_create, @args
      @resource.rights.count.should == 1
    end
    
  end
  
end
