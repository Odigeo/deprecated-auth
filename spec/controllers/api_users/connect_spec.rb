require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "PUT /api_users/1/connect" do
    
    before :each do
      permit_with 200
      @auth = create :authentication
      expect(@auth.expired?).to eq(false)
      @u = create :api_user
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
      @role = create :role
      @group = create :group
    end

    
    it "should return JSON" do
      put :connect, id: @u
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      put :connect, id: @u
      expect(response.status).to eq(400)
    end

    it "should return a 404 if the resource can't be found" do
      put :connect, id: -1
      expect(response.status).to eq(404)
      expect(response.content_type).to eq("application/json")
    end
        
    it "should return a 422 if the href query arg is nil or missing" do
      put :connect, id: @u, href: nil
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq({"_api_error" => ["href query arg is missing"]})
    end

    it "should return a 422 if the href query arg can't be parsed" do
      put :connect, id: @u, href: "gaaaaaaaaaarbage_8s67dfytuweoifjdifuya"
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq({"_api_error" => ["href query arg isn't parseable"]})
    end

    it "should return a 404 if the resource can't be found" do
      put :connect, id: @u, href: "https://example.com/v1/api_users/11111111111111111"
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({"_api_error" => ["Resource to connect not found"]})
    end

    it "should return a 204 when a group has been successfully connected" do
      put :connect, id: @u, href: group_url(@group)
      expect(response.status).to eq(204)
      @u.reload
      expect(@u.groups).to eq([@group])
    end

    it "should return a 204 when a role has been successfully connected" do
      put :connect, id: @u, href: role_url(@role)
      expect(response.status).to eq(204)
      @u.reload
      expect(@u.roles).to eq([@role])
    end

    it "should return a 422 when the connectee isn't a supported one" do
      put :connect, id: @u, href: api_user_url(create :api_user)
      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)).to eq({"_api_error" => ["Unsupported connection"]})
    end

    it "shouldn't connect the same resource more than once" do
      put :connect, id: @u, href: group_url(@group)
      expect(response.status).to eq(204)
      put :connect, id: @u, href: group_url(@group)
      expect(response.status).to eq(204)
      @u.reload
      expect(@u.groups).to eq([@group])
    end

  end
  
end
