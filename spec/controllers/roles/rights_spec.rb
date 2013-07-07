require 'spec_helper'

describe RolesController do
  
  render_views

  describe "GET roles/1/rights" do
    
    before :each do
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @it = create :role
      r1 = create :right
      r2 = create :right
      r3 = create :right
      @it.rights << r1
      @it.rights << r2
      @it.rights << r3
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
    
    
    it "should return JSON" do
      get :rights, id: @it
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :rights, id: @it
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.headers['X-API-Token'] = 'unknown, matey'
      Api.stub(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :rights, id: @it
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 403 if the X-API-Token doesn't yield GET authorisation" do
      Api.stub(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      get :rights, id: @it
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 200 when successful" do
      get :rights, id: @it
      response.should render_template(partial: 'rights/_right', count: 3)
      response.status.should == 200
    end
    
  end
  
end
