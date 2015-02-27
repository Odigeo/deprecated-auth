require 'spec_helper'

describe AuthenticationsController do
      
  render_views

  describe "DELETE" do
    
    before :each do
      Authentication.destroy_all
      permit_with 200
      @auth = create :authentication
      expect(@auth.expired?).to eq(false)
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
    end


    it "should return a 204 when successful" do
      create :authentication, token: "existent"
      delete :destroy, id: "existent"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(204)
    end  
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      delete :destroy, id: "existent"
      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
    end
            
    it "should return a 400 when the authentication was unknown" do
      create :authentication, token: "existent"
      delete :destroy, id: "nonexistent"
      expect(response.content_type).to eq("application/json")
      expect(response.status).to eq(400)
    end  
        
  end

end
