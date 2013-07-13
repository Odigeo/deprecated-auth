require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "PUT /api_users/1/connect" do
    
    before :each do
      # ApiUser.destroy_all
      # Authentication.destroy_all
      # Role.destroy_all
      # Group.destroy_all
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @auth = create :authentication
      @auth.expired?.should == false
      @u = create :api_user
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
      @role = create :role
      @group = create :group
    end

    
    it "should return JSON" do
      put :connect, id: @u
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      put :connect, id: @u
      response.status.should == 400
    end

    it "should return a 404 if the resource can't be found" do
      put :connect, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end
        
    it "should return a 422 if the href query arg is nil or missing" do
      put :connect, id: @u, href: nil
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["href query arg is missing"]}
    end

    it "should return a 422 if the href query arg can't be parsed" do
      put :connect, id: @u, href: "gaaaaaaaaaarbage_8s67dfytuweoifjdifuya"
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["href query arg isn't parseable"]}
    end

    it "should return a 404 if the resource can't be found" do
      put :connect, id: @u, href: "https://example.com/v1/api_users/11111111111111111"
      response.status.should == 404
      JSON.parse(response.body).should == {"_api_error" => ["Resource to connect not found"]}
    end

    it "should return a 204 when a group has been successfully connected" do
      put :connect, id: @u, href: group_url(@group)
      response.status.should == 204
      @u.reload
      @u.groups.should == [@group]
    end

    it "should return a 204 when a role has been successfully connected" do
      put :connect, id: @u, href: role_url(@role)
      response.status.should == 204
      @u.reload
      @u.roles.should == [@role]
    end

    it "should return a 422 when the connectee isn't a supported one" do
      put :connect, id: @u, href: api_user_url(create :api_user)
      response.status.should == 422
      JSON.parse(response.body).should == {"_api_error" => ["Unsupported connection"]}
    end

    it "shouldn't connect the same resource more than once" do
      put :connect, id: @u, href: group_url(@group)
      response.status.should == 204
      put :connect, id: @u, href: group_url(@group)
      response.status.should == 204
      @u.reload
      @u.groups.should == [@group]
    end

  end
  
end
