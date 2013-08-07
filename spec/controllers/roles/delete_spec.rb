require 'spec_helper'

describe RolesController do
  
  render_views

  describe "DELETE" do
    
    before :each do
      permit_with 200
      @role = create :role
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "so-totally-fake"
    end

    
    it "should return JSON" do
      delete :destroy, id: @role
      response.content_type.should == "application/json"
    end

    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      delete :destroy, id: @role
      response.status.should == 400
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
