require 'spec_helper'

describe RolesController do
  
  render_views

  describe "DELETE" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @role = create :role
      request.env['HTTP_ACCEPT'] = "application/json"
      request.env['X-API-Token'] = "so-totally-fake"
    end

    
    it "should return JSON" do
      delete :destroy, id: @role
      response.content_type.should == "application/json"
    end

    it "should return a 400 if the X-API-Token header is missing" do
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      request.env['X-API-Token'] = nil
      delete :destroy, id: @role
      response.status.should == 400
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      request.env['X-API-Token'] = 'unknown, matey'
      delete :destroy, id: @role
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield DELETE authorisation for Roles" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      delete :destroy, id: @role
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 204 when successful" do
      delete :destroy, id: @role
      response.status.should == 204
      response.content_type.should == "application/json"
    end

    it "should destroy the Role when successful" do
      delete :destroy, id: @role
      response.status.should == 204
      Role.find_by_id(@role.id).should be_nil
    end
    
  end
  
end
