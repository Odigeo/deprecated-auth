require 'spec_helper'

describe RolesController do
  
  render_views

  describe "PUT /roles/1/connect" do
    
    before :each do
      permit_with 200
      @auth = create :authentication
      @auth.expired?.should == false
      @x = create :role
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
      @api_user = create :api_user
      @group = create :group
      @right = create :right
    end

    
    it "should return JSON" do
      put :connect, id: @x
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      put :connect, id: @x
      response.status.should == 400
    end

    it "should return a 404 if the resource can't be found" do
      put :connect, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end
        
    it "should return a 422 if the href query arg is nil or missing" do
      put :connect, id: @x, href: nil
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["href query arg is missing"]}
    end

    it "should return a 422 if the href query arg can't be parsed" do
      put :connect, id: @x, href: "gaaaaaaaaaarbage_8s67dfytuweoifjdifuya"
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["href query arg isn't parseable"]}
    end

    it "should return a 404 if the resource can't be found" do
      put :connect, id: @x, href: "https://example.com/v1/api_users/11111111111111111"
      response.status.should == 404
      JSON.parse(response.body).should == {"_api_error" => ["Resource to connect not found"]}
    end

    it "should return a 204 when an ApiUser has been successfully connected" do
      put :connect, id: @x, href: api_user_url(@api_user)
      response.status.should == 204
      @x.reload
      @x.api_users.should == [@api_user]
    end

    it "should return a 204 when a Group has been successfully connected" do
      put :connect, id: @x, href: group_url(@group)
      response.status.should == 204
      @x.reload
      @x.groups.should == [@group]
    end

    it "should return a 204 when a Right has been successfully connected" do
      put :connect, id: @x, href: right_url(@right)
      response.status.should == 204
      @x.reload
      @x.rights.should == [@right]
    end

    it "should return a 422 when the connectee isn't a supported one" do
      put :connect, id: @x, href: role_url(create :role)
      response.status.should == 422
      JSON.parse(response.body).should == {"_api_error" => ["Unsupported connection"]}
    end

    it "shouldn't connect the same resource more than once" do
      put :connect, id: @x, href: api_user_url(@api_user)
      response.status.should == 204
      put :connect, id: @x, href: api_user_url(@api_user)
      response.status.should == 204
      @x.reload
      @x.api_users.should == [@api_user]
    end

  end
  
end
