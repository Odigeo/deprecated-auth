require 'spec_helper'

describe "roles/_role" do
  
  before :each do
    Role.destroy_all
    render partial: "roles/role", locals: {role: create(:role, indestructible: true, 
                                                        documentation_href: "http://wiki.acme.com/blah/baz")}
    @json = JSON.parse(rendered)
    @u = @json['role']
    @links = @u['_links'] rescue {}
  end
  
  
  it "has a named root" do
    @u.should_not == nil
  end


  it "should have eight hyperlinks" do
    @links.size.should == 8
  end

  it "should have a self hyperlink" do
    @links.should be_hyperlinked('self', /roles/)
  end

  it "should have a documentation hyperlink" do
     @links.should be_hyperlinked('documentation', /http:\/\/wiki.acme.com\/blah\/baz/, 'text/html')
  end

  it "should have an api_users hyperlink" do
    @links.should be_hyperlinked('api_users', /roles/)
  end

  it "should have a groups hyperlink" do
    @links.should be_hyperlinked('groups', /roles/)
  end

  it "should have a rights hyperlink" do
    @links.should be_hyperlinked('rights', /roles/)
  end

  it "should have a connect hyperlink" do
    @links.should be_hyperlinked('connect', /roles/)
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
  
  it "should have a indestructible boolean" do
    @u['indestructible'].should == true
  end
end
