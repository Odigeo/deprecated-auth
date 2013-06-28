require 'spec_helper'

describe AuthenticationsController do
      
  render_views

  describe "DELETE" do
    
    before :each do
      Api.stub!(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      @auth = create :authentication
      @auth.expired?.should == false
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = @auth.token
    end


    it "should return a 204 when successful" do
      create :authentication, token: "existent"
      #Api.stub!(:permitted?).and_return(200)
      delete :destroy, id: "existent"
      response.content_type.should == "application/json"
      response.status.should == 204
    end  
    
    it "should return a 400 when the authentication was unknown" do
      create :authentication, token: "existent"
      #Api.stub!(:permitted?).and_return(200)
      delete :destroy, id: "nonexistent"
      response.content_type.should == "application/json"
      response.status.should == 400
    end  
    
    it "should return a 403 when authorisation wasn't given" do
      create :authentication, token: "existent"
      Api.stub!(:permitted?).and_return(double(:status => 403, :body => {:_api_error => []}))
      delete :destroy, id: "nonexistent"
      response.content_type.should == "application/json"
      response.status.should == 403
    end  
    
  end

end
