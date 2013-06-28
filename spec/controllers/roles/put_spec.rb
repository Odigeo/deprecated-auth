require 'spec_helper'

describe RolesController do
  
  render_views

  describe "PUT" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "incredibly-fake!"
      @u = create :role
      @args = @u.attributes
    end

   
    it "should return JSON" do
      put :update, @args
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      put :update, @args
      response.status.should == 400
    end

    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.headers['X-API-Token'] = 'unknown, matey'
      Api.stub!(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      put :update, @args
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield PUT authorisation for ApiUsers" do
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      put :update, @args
      response.status.should == 403
      response.content_type.should == "application/json"
    end

    it "should return a 404 if the resource can't be found" do
      put :update, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end

    it "should return a 422 when resource properties are missing (all must be set simultaneously)" do
      put :update, id: @u.id
      response.status.should == 422
      response.content_type.should == "application/json"
    end

    it "should return a 409 when there is an update conflict" do
      @u.save
      put :update, id: @u, lock_version: 10, name: "Admin", description: "All rights."
      response.status.should == 409
    end
        
    it "should return a 200 when successful" do
      put :update, id: @u, lock_version: 0, name: "Admin", description: "All rights."
      response.should render_template(partial: '_role', count: 1)
      response.status.should == 200
    end


    describe "with render_views" do
      render_views

      it "should return the updated resource in the body when successful" do
        put :update, id: @u, lock_version: 0, name: "Admin", description: "All rights."
        response.status.should == 200
        JSON.parse(response.body).should be_a Hash
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

    # it "should alter the user when successful" do
    #   @u.real_name.should == "Brigitte"
    #   put :update, id: @u, lock_version: 0
    #   response.status.should == 200
    #   @u.reload
    #   @u.real_name.should == "Bardot, Brigitte"
    #   @u.email.should == "oui@example.com"
    # end

  end
  
end
