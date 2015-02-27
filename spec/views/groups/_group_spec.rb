require 'spec_helper'

describe "groups/_group" do
  
  before :each do
    Group.destroy_all
    render partial: "groups/group", locals: {group: create(:group, indestructible: true,
                                                                   documentation_href: "http://wiki.acme.com/blah/baz")}
    @json = JSON.parse(rendered)
    @u = @json['group']
    @links = @u['_links'] rescue {}
  end
  

  it "has a named root" do
    expect(@u).not_to eq(nil)
  end


  it "should have eight hyperlinks" do
    expect(@links.size).to eq(8)
  end

  it "should have a self hyperlink" do
    expect(@links).to be_hyperlinked('self', /groups/)
  end

  it "should have a documentation hyperlink" do
     expect(@links).to be_hyperlinked('documentation', /http:\/\/wiki.acme.com\/blah\/baz/, 'text/html')
  end

  it "should have an api_users hyperlink" do
    expect(@links).to be_hyperlinked('api_users', /groups/)
  end

  it "should have a roles hyperlink" do
    expect(@links).to be_hyperlinked('roles', /groups/)
  end

  it "should have a rights hyperlink" do
    expect(@links).to be_hyperlinked('rights', /groups/)
  end

  it "should have a connect hyperlink" do
    expect(@links).to be_hyperlinked('connect', /groups/)
  end

  it "should have a creator hyperlink" do
     expect(@links).to be_hyperlinked('creator', /api_users/)
  end

  it "should have a updater hyperlink" do
     expect(@links).to be_hyperlinked('updater', /api_users/)
  end


  it "should have a created_at time" do
    expect(@u['created_at']).to be_a String
  end

  it "should have an updated_at time" do
    expect(@u['updated_at']).to be_a String
  end

  it "should have a lock_version field" do
    expect(@u['lock_version']).to be_an Integer
  end
 
  it "should have a name" do
    expect(@u['name']).to be_a String
  end

  it "should have a description" do
    expect(@u['description']).to be_a String
  end
  
  it "should have a indestructible boolean" do
    expect(@u['indestructible']).to eq(true)
  end
end
