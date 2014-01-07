require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "DELETE" do
    
    before :each do
      permit_with 200
      @auth = create :authentication
      @auth.expired?.should == false
      @api_user = create :api_user
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
    end


    it "should return JSON" do
      delete :destroy, id: @api_user
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      delete :destroy, id: @api_user
      response.status.should == 400
    end

    it "should return a 403 if indestructible" do
      @api_user.indestructible = true
      @api_user.save
      delete :destroy, id: @api_user
      response.status.should == 403
    end
            
    it "should return a 204 when successful" do
      delete :destroy, id: @api_user
      response.status.should == 204
      response.content_type.should == "application/json"
    end

    it "should destroy the user when successful" do
      delete :destroy, id: @api_user
      response.status.should == 204
      ApiUser.find_by_id(@api_user).should be_nil
    end
    
  end
  
end
