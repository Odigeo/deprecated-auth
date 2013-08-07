require 'spec_helper'

describe ResourcesController do
  
  render_views

  describe "INDEX" do
    
    before :each do
      permit_with 200
      create :resource
      create :resource
      create :resource
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
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
      response.should render_template(partial: '_resource', count: 3)
      response.status.should == 200
    end

    it "should return a collection" do
      get :index
      response.status.should == 200
      JSON.parse(response.body).should be_an Array
    end

    it "should accept match and search parameters" do
      Resource.should_receive(:index).with(anything, nil, 'ue').and_return([])
      get :index, app: 'foo', search: 'ue'
      response.status.should == 200
    end
    
    it "should accept a group parameter" do
      Resource.should_receive(:index).with(anything, 'name', nil).and_return([])
      get :index, app: 'foo', group: :name
      response.status.should == 200
    end
    
  end
  
end
