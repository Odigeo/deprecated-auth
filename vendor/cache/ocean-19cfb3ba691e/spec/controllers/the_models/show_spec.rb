require 'spec_helper'

describe TheModelsController do
  
  render_views

  describe "GET" do
    
    before :each do
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      Api.stub(:call_p)
      @the_model = create :the_model
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "totally-fake"
    end


    it "should return JSON" do
      get :show, id: @the_model
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :show, id: @the_model
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      request.headers['X-API-Token'] = 'unknown, matey'
      Api.stub(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      get :show, id: @the_model
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield GET authorisation for TheModels" do
      Api.stub(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      get :show, id: @the_model
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 404 when the user can't be found" do
      get :show, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :show, id: @the_model
      response.status.should == 200
      response.should render_template(partial: "_the_model", count: 1)
    end
    
  end
  
end