require 'spec_helper'

describe RolesController do
  
  render_views

  describe "PUT" do
    
    before :each do
      permit_with 200
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "incredibly-fake!"
      @u = create :role
      @args = @u.attributes
    end

   
    it "should return JSON" do
      put :update, @args
      expect(response.content_type).to eq("application/json")
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      put :update, @args
      expect(response.status).to eq(400)
    end

    it "should return a 404 if the resource can't be found" do
      put :update, id: -1
      expect(response.status).to eq(404)
      expect(response.content_type).to eq("application/json")
    end

    it "should return a 422 when resource properties are missing (all must be set simultaneously)" do
      put :update, id: @u.id
      expect(response.status).to eq(422)
      expect(response.content_type).to eq("application/json")
    end

    it "should return a 409 when there is an update conflict" do
      @u.save
      put :update, id: @u, lock_version: 10, name: "Admin", description: "All rights."
      expect(response.status).to eq(409)
    end
        
    it "should return a 200 when successful" do
      put :update, id: @u, lock_version: 0, name: "Admin", description: "All rights."
      expect(response).to render_template(partial: '_role', count: 1)
      expect(response.status).to eq(200)
    end


    describe "with render_views" do
      render_views

      it "should return the updated resource in the body when successful" do
        put :update, id: @u, lock_version: 0, name: "Admin", description: "All rights."
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to be_a Hash
      end

      # Uncomment this test as soon as there is one or more DB attributes that need
      # validating.
      #
      # it "should return a 422 when there are validation errors" do
      #   put :update, @args.merge(:locale => "nix-DORF")
      #   response.status.should == 422
      #   response.content_type.should == "application/json"
      #   JSON.parse(response.body).should == {"locale"=>["ISO language code format required ('de-AU')"]}
      # end

    end

    it "should alter the role when successful, except for the indestructible flag" do
      put :update, id: @u, name: "secret role", description: "very descriptive",
                           indestructible: true, lock_version: 0, documentation_href: "http://acme.com"
      expect(response.status).to eq(200)
      @u.reload
      expect(@u.name).to eq("secret role")
      expect(@u.description).to eq("very descriptive")
      expect(@u.indestructible).to eq(false)
      @u.documentation_href == "http://acme.com"
    end
  end
  
end
