require 'spec_helper'

describe ServicesController do
  
  render_views

  describe "INDEX" do
    
    before :each do
      Api.stub(:permitted?).and_return(double(:status => 200, 
                                               :body => {'authentication' => {'user_id' => 123}}))
      create :service
      create :service
      create :service
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
      response.should render_template(partial: "_service", count: 3)
      response.status.should == 200
    end

    it "should return a collection" do
      get :index
      response.status.should == 200
      JSON.parse(response.body).should be_an Array
    end

    it "should accept match and search parameters" do
      Service.should_receive(:index).with(anything, nil, 'ue').and_return([])
      get :index, app: 'foo', search: 'ue'
      response.status.should == 200
    end
    
    it "should accept a group parameter" do
      Service.should_receive(:index).with(anything, 'name', nil).and_return([])
      get :index, app: 'foo', group: :name
      response.status.should == 200
    end
    
  end
  
end
