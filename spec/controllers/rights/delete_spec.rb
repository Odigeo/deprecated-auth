require 'spec_helper'

describe RightsController do
  
  render_views

  describe "DELETE" do
    
    before :each do
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @right = create :right
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "so-totally-fake"
    end

    
    it "should render null" do
      delete :destroy, id: @right
      response.body.should == ''
    end

    it "should return JSON" do
      delete :destroy, id: @right
      response.content_type.should == "application/json"
    end

    it "should return a 400 if the X-API-Token header is missing" do
      Api.stub(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      request.headers['X-API-Token'] = nil
      delete :destroy, id: @right
      response.status.should == 400
    end
    
    it "should return a 400 if the authentication represented by the X-API-Token can't be found" do
      Api.stub(:permitted?).and_return(double(:status => 400, :body => {:_api_error => []}))
      request.headers['X-API-Token'] = 'unknown, matey'
      delete :destroy, id: @right
      response.status.should == 400
      response.content_type.should == "application/json"
    end

    it "should return a 403 if the X-API-Token doesn't yield DELETE authorisation for Rights" do
      Api.stub(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      delete :destroy, id: @right
      response.status.should == 403
      response.content_type.should == "application/json"
    end
        
    it "should return a 204 when successful" do
      delete :destroy, id: @right
      response.status.should == 204
      response.content_type.should == "application/json"
    end

    it "should destroy the Right when successful" do
      delete :destroy, id: @right
      response.status.should == 204
      Right.find_by_id(@right.id).should be_nil
    end
    
  end
  
end
