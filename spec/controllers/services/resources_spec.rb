require 'spec_helper'

describe ServicesController do
  
  render_views

  describe "GET resources" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @s1 = create :service
      @r1 = create :resource, service: @s1
      @r2 = create :resource, service: @s1
      @s2 = create :service
      @r3 = create :resource, service: @s2
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
    
    
    it "should return JSON" do
      get :resources, id: @s1
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :resources, id: @s1
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.headers['X-API-Token'] = 'unknown, matey'
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :resources, id: @s1
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 403 if the X-API-Token doesn't yield GET authorisation for Services" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      get :resources, id: @s1
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 200 when successful" do
      get :resources, id: @s1
      response.should render_template(partial: "resources/_resource", count: 2)
      response.status.should == 200
    end
    
  end
  
end
