require 'spec_helper'

describe <%= class_name.pluralize %>Controller do
  
  render_views

  describe "DELETE" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @<%= singular_name %> = create :<%= singular_name %>
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "so-totally-fake"
    end

    
    it "should return JSON" do
      delete :destroy, id: @<%= singular_name %>
      response.content_type.should == "application/json"
    end

    it "should return a 400 if the X-API-Token header is missing" do
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      request.headers['X-API-Token'] = nil
      delete :destroy, id: @<%= singular_name %>
      response.status.should == 400
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      request.headers['X-API-Token'] = 'unknown, matey'
      delete :destroy, id: @<%= singular_name %>
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield DELETE authorisation for <%= class_name.pluralize %>" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      delete :destroy, id: @<%= singular_name %>
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 204 when successful" do
      delete :destroy, id: @<%= singular_name %>
      response.status.should == 204
      response.content_type.should == "application/json"
    end

    it "should return a 404 when the <%= class_name %> can't be found" do
      delete :destroy, id: -1
      response.status.should == 404
    end
    
    it "should destroy the <%= class_name %> when successful" do
      delete :destroy, id: @<%= singular_name %>
      response.status.should == 204
      <%= class_name %>.find_by_id(@<%= singular_name %>.id).should be_nil
    end
    
  end
  
end