require 'spec_helper'

describe GroupsController do
  
  render_views

  describe "DELETE /groups/1/connect" do
    
    before :each do
      permit_with 200
      @auth = create :authentication
      @auth.expired?.should == false
      @x = create :group
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
      @api_user = create :api_user
      @role = create :role
      @right = create :right
    end
 
   
    it "should return JSON" do
      delete :disconnect, id: @x
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      delete :disconnect, id: @x
      response.status.should == 400
    end

    it "should return a 404 if the resource can't be found" do
      delete :disconnect, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end
        
    it "should return a 422 if the href query arg is nil or missing" do
      delete :disconnect, id: @x, href: nil
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["href query arg is missing"]}
    end

    it "should return a 422 if the href query arg can't be parsed" do
      delete :disconnect, id: @x, href: "gaaaaaaaaaarbage_8s67dfytuweoifjdifuya"
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"_api_error" => ["href query arg isn't parseable"]}
    end

    it "should return a 404 if the resource can't be found" do
      delete :disconnect, id: @x, href: "https://example.com/v1/api_users/11111111111111111"
      response.status.should == 404
      JSON.parse(response.body).should == {"_api_error" => ["Resource to connect not found"]}
    end

    it "should return a 204 when an ApiUser has been successfully disconnected" do
      @x.api_users << @api_user
      delete :disconnect, id: @x, href: api_user_url(@api_user)
      response.status.should == 204
      @x.reload
      @x.api_users.should == []
    end

    it "should return a 204 when a Role has been successfully disconnected" do
      @x.roles << @role
      delete :disconnect, id: @x, href: role_url(@role)
      response.status.should == 204
      @x.reload
      @x.roles.should == []
    end

    it "should return a 204 when a Right has been successfully disconnected" do
      @x.rights << @right
      delete :disconnect, id: @x, href: right_url(@right)
      response.status.should == 204
      @x.reload
      @x.rights.should == []
    end

    it "should return a 422 when the connectee isn't a supported one" do
      delete :disconnect, id: @x, href: group_url(create :group)
      response.status.should == 422
      JSON.parse(response.body).should == {"_api_error" => ["Unsupported connection"]}
    end

    it "shouldn't signal an error for a non-connected resource" do
      @x.api_users << @api_user
      delete :disconnect, id: @x, href: api_user_url(@api_user)
      response.status.should == 204
      delete :disconnect, id: @x, href: api_user_url(@api_user)
      response.status.should == 204
      @x.reload
      @x.api_users.should == []
    end

  end
  
end
