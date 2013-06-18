require 'spec_helper'

describe "resources/_resource" do
  
  before :each do
    Service.destroy_all
    render partial: "resources/resource", locals: {resource: create(:resource)}
    @json = JSON.parse(rendered)
    @u = @json['resource']
    @links = @u['_links'] rescue {}
  end
  

  it "has a named root" do
    @u.should_not == nil
  end


  it "should have five hyperlinks" do
    @links.size.should == 5
  end

  it "should have a self hyperlink" do
     @links.should be_hyperlinked('self', /resources/)
  end

  it "should have a service hyperlink" do
     @links.should be_hyperlinked('service', /resources/)
  end

  it "should have a rights hyperlink" do
     @links.should be_hyperlinked('rights', /resources/)
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
