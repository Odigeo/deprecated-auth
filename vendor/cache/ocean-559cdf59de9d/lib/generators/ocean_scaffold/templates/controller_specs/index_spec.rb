require 'spec_helper'

describe <%= class_name.pluralize %>Controller do
  
  render_views

  describe "INDEX" do
    
    before :each do
      permit_with 200
      create :<%= singular_name %>
      create :<%= singular_name %>
      create :<%= singular_name %>
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
      response.status.should == 200
      response.should render_template(partial: "_<%= singular_name %>", count: 3)
    end

    it "should accept match and search parameters" do
      <%= class_name %>.should_receive(:collection).
        with({"app"=>"foo", "search"=>"ue", "controller"=><%= plural_name %>, "action"=>"index"}).
        and_return([])
      get :index, app: 'foo', search: 'ue'
      response.status.should == 200
    end
    
    it "should accept a group parameter" do
      <%= class_name %>.should_receive(:collection).
        with({"app"=>"foo", "group"=>"name", "controller"=><%= plural_name %>, "action"=>"index"}).
        and_return([])
      get :index, app: 'foo', group: :name
      response.status.should == 200
    end
    
  end
  
end