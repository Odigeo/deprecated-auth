require 'spec_helper'

describe "rights/_right" do
  
  before :each do                     # Must be :each (:all causes all tests to fail)
    Service.destroy_all
    Right.destroy_all
    render partial: "rights/right", locals: {right: create(:right)}
    @json = JSON.parse(rendered)
    @u = @json['right']
    @links = @u['_links'] rescue {}
  end
  
  
  it "has a named root" do
    expect(@u).not_to eq(nil)
  end


  it "should have six hyperlinks" do
    expect(@links.size).to eq(6)
  end

  it "should have a self hyperlink" do
    expect(@links).to be_hyperlinked('self', /rights/)
  end

  it "should have a resource hyperlink" do
    expect(@links).to be_hyperlinked('resource', /resources/)
  end

  it "should have a service hyperlink" do
    expect(@links).to be_hyperlinked('service', /services/)
  end

  it "should have a connect hyperlink" do
    expect(@links).to be_hyperlinked('connect', /rights/)
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

  it "should have a hyperlink" do
    expect(@u['hyperlink']).to be_a String
  end
      
  it "should have a verb" do
    expect(@u['verb']).to be_a String
  end
      
  it "should have an app" do
    expect(@u['app']).to be_a String
  end
      
  it "should have a context" do
    expect(@u['context']).to be_a String
  end

end
