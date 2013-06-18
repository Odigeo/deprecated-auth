require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "DELETE /api_users/1/connect" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @auth = create :authentication
      @auth.expired?.should == false
      @u = create :api_user
      request.env['HTTP_ACCEPT'] = "application/json"
      request.env['X-API-Token'] = @auth.token
      @role = create :role
      @group = create :group
    end

   
    it "should return JSON" do
      delete :disconnect, id: @u
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.env['X-API-Token'] = nil
      delete :disconnect, id: @u
      response.status.should == 400
    end

    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.env['X-API-Token'] = 'unknown, matey'
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      delete :disconnect, id: @u
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 400 if the authentication represented by the X-API-Token has expired" do
      @auth = create :authentication, created_at: 1.year.ago.utc, expires_at: 1.year.ago.utc
      @auth.expired?.should == true
      request.env['X-API-Token'] = @auth.token
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      delete :disconnect, id: @u
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 403 if the X-API-Token doesn't yield PUT authorisation for ApiUsers" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      delete :disconnect, id: @u
      response.status.should == 403
      response.content_type.should == "application/json"
    end

    it "should return a 404 if the resource can't be found" do
      delete :disconnect, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end
        
    it "should return a 422 if the href query arg is nil or missing" do
      delete :disconnect, id: @u, href: nil
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["href query arg is missing"]}
    end

    it "should return a 422 if the href query arg can't be parsed" do
      delete :disconnect, id: @u, href: "gaaaaaaaaaarbage_8s67dfytuweoifjdifuya"
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["href query arg isn't parseable"]}
    end

    it "should return a 404 if the resource can't be found" do
      delete :disconnect, id: @u, href: "https://example.com/v1/api_users/11111111111111111"
      response.status.should == 404
      JSON.parse(response.body).should == {"_api_error" => ["Resource to connect not found"]}
    end

    it "should return a 204 when a group has been successfully disconnected" do
      @u.groups << @group
      delete :disconnect, id: @u, href: group_url(@group)
      response.status.should == 204
      @u.reload
      @u.groups.should == []
    end

    it "should return a 204 when a role has been successfully disconnected" do
      @u.roles << @role
      delete :disconnect, id: @u, href: role_url(@role)
      response.status.should == 204
      @u.reload
      @u.roles.should == []
    end

    it "should return a 422 when the connectee isn't a supported one" do
      delete :disconnect, id: @u, href: api_user_url(create :api_user)
      response.status.should == 422
      JSON.parse(response.body).should == {"_api_error" => ["Unsupported connection"]}
    end

    it "shouldn't signal an error for a non-connected resource" do
      @u.groups << @group
      delete :disconnect, id: @u, href: group_url(@group)
      response.status.should == 204
      delete :disconnect, id: @u, href: group_url(@group)
      response.status.should == 204
      @u.reload
      @u.groups.should == []
    end

  end
  
end
