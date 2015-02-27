require 'spec_helper'

describe ApiUsersController do
  
  render_views

  describe "PUT" do
    
    before :each do
      permit_with 200
      @auth = create :authentication
      expect(@auth.expired?).to eq(false)
      @u = create :api_user, username: "brigitte_bardot", real_name: "Brigitte", email: "non@example.com"
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
    end


    it "should render the object partial" do
      put :update, id: @u, username: "brigitte_bardot", real_name: "Brigitte", email: "oui@example.com", lock_version: 0
      expect(response).to render_template(partial: '_api_user', count: 1)
    end
    
    it "should return JSON" do
      put :update, id: @u
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      put :update, id: @u
      expect(response.status).to eq(400)
    end

    it "should return a 404 if the resource can't be found" do
      put :update, id: -1
      expect(response.status).to eq(404)
      expect(response.content_type).to eq("application/json")
    end

    it "should return a 422 when resource properties are missing (all must be set simultaneously)" do
      put :update, id: @u
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
    end

    it "should return a 422 when there are validation errors" do
      put :update, id: @u, username: "brigitte_bardot", real_name: "Brigitte", email: "oui@example.com", lock_version: 10,
                           authentication_duration: -3.14,
                           shared_tokens: "not a boolean"
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
      expect(JSON.parse(response.body)).to eq( 
        {"authentication_duration" => ["must be an integer"]}
      )
    end

    it "should return a 409 when there is an update conflict" do
      @u.save
      put :update, id: @u, username: "brigitte_bardot", real_name: "Brigitte", email: "oui@example.com", lock_version: 10
      expect(response.status).to eq(409)
    end
        
    it "should return a 200 when successful" do
      put :update, id: @u, username: "brigitte_bardot", real_name: "Brigitte", email: "oui@example.com", lock_version: 0
      expect(response.status).to eq(200)
    end

    describe "with render_views" do
      render_views
      it "should return the updated resource in the body when successful" do
        put :update, id: @u, username: "brigitte_bardot", real_name: "Brigitte B.", email: "oui@example.com", lock_version: 0
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to be_a Hash
      end
    end

    it "should alter the user when successful, except for the indestructible flag" do
      expect(@u.real_name).to eq("Brigitte")
      put :update, id: @u, username: "brigitte_bardot", real_name: "Bardot, Brigitte", email: "oui@example.com", lock_version: 0,
                           authentication_duration: 1.year.to_i,
                           indestructible: true
      expect(response.status).to eq(200)
      @u.reload
      expect(@u.real_name).to eq("Bardot, Brigitte")
      expect(@u.email).to eq("oui@example.com")
      expect(@u.authentication_duration).to eq(1.year.to_i)
      expect(@u.indestructible).to eq(false)
    end

    it "should hash any new password given" do
      old_pw_hash = @u.password_hash
      put :update, id: @u, username: "brigitte_bardot", password: "AnimalRightsDammit!", real_name: "Sock! Pow!", 
                   email: "oui@example.com", lock_version: 0
      expect(response.status).to eq(200)
      @u.reload
      expect(@u.password_hash).not_to eq(old_pw_hash)
    end
    
    it "should not change the password_hash unless a new password is given" do
      old_pw_hash = @u.password_hash
      put :update, id: @u, username: "brigitte_bardot", real_name: "Sock! Pow!", email: "oui@example.com", lock_version: 0
      expect(response.status).to eq(200)
      @u.reload
      expect(@u.password_hash).to eq(old_pw_hash)
    end

  end
  
end
