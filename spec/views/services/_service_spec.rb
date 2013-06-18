require 'spec_helper'

describe "services/show" do
  
  before :each do
    Service.destroy_all
    render partial: "services/service", locals: {service: create(:service)}
    @json = JSON.parse(rendered)
    @u = @json['service']
    @links = @u['_links'] rescue {}
  end
  
  
  it "has a named root" do
    @u.should_not == nil
  end


  it "should have four hyperlinks" do
    @links.size.should == 4
  end

  it "should have a self hyperlink" do
    @links.should be_hyperlinked('self', /services/)
  end

  it "should have a resources hyperlink" do
    @links.should be_hyperlinked('resources', /services/)
  end

  it "should have a creator hyperlink" do
    @links.should be_hyperlinked('creator', /api_users/)
  end

  it "should have a updater hyperlink" do
    @links.should be_hyperlinked('updater', /api_users/)
  end


  it "should have a created_at time" do
    @u['created_at'].should be_a String
  end

  it "should have an updated_at time" do
    @u['updated_at'].should be_a String
  end

  it "should have a lock_version field" do
    @u['lock_version'].should be_an Integer
  end
  
end
