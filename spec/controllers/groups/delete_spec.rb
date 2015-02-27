require 'spec_helper'

describe GroupsController do
  
  render_views

  describe "DELETE" do
    
    before :each do
      permit_with 200
      @group = create :group
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "so-totally-fake"
    end

    
    it "should return JSON" do
      delete :destroy, id: @group
      expect(response.content_type).to eq("application/json")
    end

    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      delete :destroy, id: @group
      expect(response.status).to eq(400)
    end
            
    it "should return a 403 if indestructible" do
      @group.indestructible = true
      @group.save
      delete :destroy, id: @group
      expect(response.status).to eq(403)
    end
            
    it "should return a 204 when successful" do
      delete :destroy, id: @group
      expect(response.status).to eq(204)
      expect(response.content_type).to eq("application/json")
    end

    it "should destroy the Group when successful" do
      delete :destroy, id: @group
      expect(response.status).to eq(204)
      expect(Group.find_by_id(@group.id)).to be_nil
    end
    
  end
  
end
