require 'spec_helper'

describe RightsController do
  
  render_views

  describe "PUT" do
    
    before :each do
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "incredibly-fake!"
      @u = create :right
      @args = @u.attributes
    end

    
    it "should render the object partial" do
      put :update, @args
      response.should render_template(partial: '_right', count: 1)
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
      Api.stub(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      put :update, @args
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield PUT authorisation for ApiUsers" do
      Api.stub(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
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
    
    it "should return a 422 when there are validation errors" do
      put :update, @args.merge('hyperlink' => "Not correct")
      response.status.should == 422
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {"hyperlink"=>["may only contain the characters a-z, 0-9, and underscores, and must start with a lowercase letter"]} 
    end

    it "should return a 409 when there is an update conflict" do
      @u.save
      put :update, @args.merge('lock_version' => 10)
      response.status.should == 409
    end
        
    it "should return a 200 when successful" do
      put :update, @args
      response.status.should == 200
    end

    describe "with render_views" do
      render_views
      it "should return the updated resource in the body when successful" do
        put :update, @args
        response.status.should == 200
        JSON.parse(response.body).should be_a Hash
      end
    end

    it "should alter the resource when successful" do
      @u.description.should == "This is a description of the Right."
      @args['description'] = "Zalagadoola"
      put :update, @args, lock_version: 0
      response.status.should == 200
      @u.reload
      @u.description.should == "Zalagadoola"
    end

  end
  
end
