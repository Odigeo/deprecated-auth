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
    @u.should_not == nil
  end


  it "should have six hyperlinks" do
    @links.size.should == 6
  end

  it "should have a self hyperlink" do
    @links.should be_hyperlinked('self', /rights/)
  end

  it "should have a resource hyperlink" do
    @links.should be_hyperlinked('resource', /resources/)
  end

  it "should have a service hyperlink" do
    @links.should be_hyperlinked('service', /services/)
  end

  it "should have a connect hyperlink" do
    @links.should be_hyperlinked('connect', /rights/)
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

  it "should have a hyperlink" do
    @u['hyperlink'].should be_a String
  end
      
  it "should have a verb" do
    @u['verb'].should be_a String
  end
      
  it "should have an app" do
    @u['app'].should be_a String
  end
      
  it "should have a context" do
    @u['context'].should be_a String
  end

end
