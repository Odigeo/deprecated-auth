require 'spec_helper'

describe RightsController do
  
  render_views

  describe "DELETE" do
    
    before :each do
      permit_with 200
      @right = create :right
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "so-totally-fake"
    end

    
    it "should render null" do
      delete :destroy, id: @right
      expect(response.body).to eq('')
    end

    it "should return JSON" do
      delete :destroy, id: @right
      expect(response.content_type).to eq("application/json")
    end

    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      delete :destroy, id: @right
      expect(response.status).to eq(400)
    end
    
    it "should return a 204 when successful" do
      delete :destroy, id: @right
      expect(response.status).to eq(204)
      expect(response.content_type).to eq("application/json")
    end

    it "should destroy the Right when successful" do
      delete :destroy, id: @right
      expect(response.status).to eq(204)
      expect(Right.find_by_id(@right.id)).to be_nil
    end
    
  end
  
end