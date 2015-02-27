require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "DELETE" do
    
    before :each do
      permit_with 200
      @auth = create :authentication
      expect(@auth.expired?).to eq(false)
      @api_user = create :api_user
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
    end


    it "should return JSON" do
      delete :destroy, id: @api_user
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      delete :destroy, id: @api_user
      expect(response.status).to eq(400)
    end

    it "should return a 403 if indestructible" do
      @api_user.indestructible = true
      @api_user.save
      delete :destroy, id: @api_user
      expect(response.status).to eq(403)
    end
            
    it "should return a 204 when successful" do
      delete :destroy, id: @api_user
      expect(response.status).to eq(204)
      expect(response.content_type).to eq("application/json")
    end

    it "should destroy the user when successful" do
      delete :destroy, id: @api_user
      expect(response.status).to eq(204)
      expect(ApiUser.find_by_id(@api_user)).to be_nil
    end
    
  end
  
end
