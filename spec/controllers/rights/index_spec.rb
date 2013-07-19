require 'spec_helper'

describe RightsController do
  
  render_views

  describe "INDEX" do
    
    before :each do
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      create :right
      create :right
      create :right
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end
    
    
    it "should render the object partial" do
      get :index
      response.should render_template(partial: '_right', count: 3)
    end

    it "should return JSON" do
      get :index
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :index
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :index
      response.status.should == 200
    end

    it "should return a collection" do
      get :index
      response.status.should == 200
      JSON.parse(response.body).should be_an Array
    end

    it "should accept match and search parameters" do
      Right.should_receive(:index).with(anything, nil, 'ue').and_return([])
      get :index, app: 'foo', search: 'ue'
      response.status.should == 200
    end
    
    it "should accept a group parameter" do
      Right.should_receive(:index).with(anything, 'context', nil).and_return([])
      get :index, app: 'foo', group: :context
      response.status.should == 200
    end
    
  end
  
end
