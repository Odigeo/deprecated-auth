require 'spec_helper'

describe "api_users/_api_user" do
  
  before :each do                     # Must be :each (:all causes all tests to fail)
    ApiUser.destroy_all
    render partial: "api_users/api_user", locals: {api_user: create(:api_user, indestructible: true)}
    @json = JSON.parse(rendered)
    @u = @json['api_user']
    @links = @u['_links'] rescue {}
  end
  

  it "has a named root" do
    @u.should_not == nil
  end


  it "should have eight hyperlinks" do
    @links.size.should == 8
  end

  it "should have a self hyperlink" do
    @links.should be_hyperlinked('self', /api_users/)
  end

  it "should have an authentications hyperlink" do
    @links.should be_hyperlinked('authentications', /api_users/)
  end

  it "should have a roles hyperlink" do
    @links.should be_hyperlinked('roles', /api_users/)
  end

  it "should have a groups hyperlink" do
    @links.should be_hyperlinked('groups', /api_users/)
  end

  it "should have a rights hyperlink" do
    @links.should be_hyperlinked('rights', /api_users/)
  end

  it "should have a connect hyperlink" do
    @links.should be_hyperlinked('connect', /api_users/)
  end

  it "should have a creator hyperlink" do
    @links.should be_hyperlinked('creator', /api_users/)
  end

  it "should have a updater hyperlink" do
    @links.should be_hyperlinked('updater', /api_users/)
  end


  it "should have a username" do
    @u['username'].should be_a String
  end

  it "should have a real name" do
    @u['real_name'].should be_a String
  end

  it "should not expose the hashed password" do
    @u['password_hash'].should == nil
  end

  it "should not expose the salt" do
    @u['password_salt'].should == nil
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

  it "should have an email field" do
    @u['email'].should be_a String
  end

  it "should have an authentication_duration" do
    @u['authentication_duration'].should be_an Integer
  end

  it "should have a login_blocked boolean" do
    @u['login_blocked'].should == false
  end

  it "should have a login_blocked_reason" do
    @u['login_blocked_reason'].should == nil
  end

  it "should have a indestructible boolean" do
    @u['indestructible'].should == true
  end

end
