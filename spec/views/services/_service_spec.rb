require 'spec_helper'

describe "services/show" do
  
  before :each do
    Service.destroy_all
    render partial: "services/service", 
      locals: {service: create(:service, documentation_href: "http://wiki.acme.com/blah/baz")}
    @json = JSON.parse(rendered)
    @u = @json['service']
    @links = @u['_links'] rescue {}
  end
  
  
  it "has a named root" do
    expect(@u).not_to eq(nil)
  end


  it "should have five hyperlinks" do
    expect(@links.size).to eq(6)
  end

  it "should have a self hyperlink" do
    expect(@links).to be_hyperlinked('self', /services/)
  end

  it "should have a resources hyperlink" do
    expect(@links).to be_hyperlinked('resources', /services/)
  end

  it "should have a creator hyperlink" do
    expect(@links).to be_hyperlinked('creator', /api_users/)
  end

  it "should have a updater hyperlink" do
    expect(@links).to be_hyperlinked('updater', /api_users/)
  end

  it "should have an instances hyperlink" do
    expect(@links).to be_hyperlinked('instances', /instances/)
  end

  it "should have a documentation hyperlink" do
     expect(@links).to be_hyperlinked('documentation', /http:\/\/wiki.acme.com\/blah\/baz/, 'text/html')
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
  
end
