require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "PUT" do
    
    before :each do
      permit_with 200
      @auth = create :authentication
      @auth.expired?.should == false
      @u = create :api_user, username: "brigitte_bardot", real_name: "Brigitte", email: "non@example.com"
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
    end


    it "should render the object partial" do
      put :update, id: @u, username: "brigitte_bardot", real_name: "Brigitte", email: "oui@example.com", lock_version: 0
      response.should render_template(partial: '_api_user', count: 1)
    end
    
    it "should return JSON" do
      put :update, id: @u
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      put :update, id: @u
      response.status.should == 400
    end

    it "should return a 404 if the resource can't be found" do
      put :update, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end

    it "should return a 422 when resource properties are missing (all must be set simultaneously)" do
      put :update, id: @u
      response.status.should == 422
      response.content_type.should == "application/json"
    end

    it "should return a 422 when there are validation errors" do
      put :update, id: @u, username: "brigitte_bardot", real_name: "Brigitte", email: "oui@example.com", lock_version: 10,
                           authentication_duration: -3.14,
                           shared_tokens: "not a boolean"
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == 
        {"authentication_duration" => ["must be an integer"]}
    end

    it "should return a 409 when there is an update conflict" do
      @u.save
      put :update, id: @u, username: "brigitte_bardot", real_name: "Brigitte", email: "oui@example.com", lock_version: 10
      response.status.should == 409
    end
        
    it "should return a 200 when successful" do
      put :update, id: @u, username: "brigitte_bardot", real_name: "Brigitte", email: "oui@example.com", lock_version: 0
      response.status.should == 200
    end

    describe "with render_views" do
      render_views
      it "should return the updated resource in the body when successful" do
        put :update, id: @u, username: "brigitte_bardot", real_name: "Brigitte B.", email: "oui@example.com", lock_version: 0
        response.status.should == 200
        JSON.parse(response.body).should be_a Hash
      end
    end

    it "should alter the user when successful, except for the indestructible flag" do
      @u.real_name.should == "Brigitte"
      put :update, id: @u, username: "brigitte_bardot", real_name: "Bardot, Brigitte", email: "oui@example.com", lock_version: 0,
                           authentication_duration: 1.year.to_i,
                           shared_tokens: true,
                           indestructible: true
      response.status.should == 200
      @u.reload
      @u.real_name.should == "Bardot, Brigitte"
      @u.email.should == "oui@example.com"
      @u.authentication_duration.should == 1.year.to_i
      @u.shared_tokens.should == true
      @u.indestructible.should == false
    end

    it "should hash any new password given" do
      old_pw_hash = @u.password_hash
      put :update, id: @u, username: "brigitte_bardot", password: "AnimalRightsDammit!", real_name: "Sock! Pow!", 
                   email: "oui@example.com", lock_version: 0
      response.status.should == 200
      @u.reload
      @u.password_hash.should_not == old_pw_hash
    end
    
    it "should not change the password_hash unless a new password is given" do
      old_pw_hash = @u.password_hash
      put :update, id: @u, username: "brigitte_bardot", real_name: "Sock! Pow!", email: "oui@example.com", lock_version: 0
      response.status.should == 200
      @u.reload
      @u.password_hash.should == old_pw_hash
    end

  end
  
end
