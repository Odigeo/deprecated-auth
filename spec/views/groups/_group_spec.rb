require 'spec_helper'

describe "groups/_group" do
  
  before :each do
    Group.destroy_all
    render partial: "groups/group", locals: {group: create(:group)}
    @json = JSON.parse(rendered)
    @u = @json['group']
    @links = @u['_links'] rescue {}
  end
  

  it "has a named root" do
    @u.should_not == nil
  end


  it "should have seven hyperlinks" do
    @links.size.should == 7
  end

  it "should have a self hyperlink" do
    @links.should be_hyperlinked('self', /groups/)
  end

  it "should have an api_users hyperlink" do
    @links.should be_hyperlinked('api_users', /groups/)
  end

  it "should have a roles hyperlink" do
    @links.should be_hyperlinked('roles', /groups/)
  end

  it "should have a rights hyperlink" do
    @links.should be_hyperlinked('rights', /groups/)
  end

  it "should have a connect hyperlink" do
    @links.should be_hyperlinked('connect', /groups/)
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
 
  it "should have a name" do
    @u['name'].should be_a String
  end

  it "should have a description" do
    @u['description'].should be_a String
  end
  
end
