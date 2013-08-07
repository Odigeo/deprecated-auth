require 'spec_helper'

describe RightsController do
  
  render_views

  describe "DELETE" do
    
    before :each do
      permit_with 200
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
      request.headers['X-API-Token'] = nil
      delete :destroy, id: @right
      response.status.should == 400
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
