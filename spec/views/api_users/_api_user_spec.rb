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
    expect(@u).not_to eq(nil)
  end


  it "should have eight hyperlinks" do
    expect(@links.size).to eq(8)
  end

  it "should have a self hyperlink" do
    expect(@links).to be_hyperlinked('self', /api_users/)
  end

  it "should have an authentications hyperlink" do
    expect(@links).to be_hyperlinked('authentications', /api_users/)
  end

  it "should have a roles hyperlink" do
    expect(@links).to be_hyperlinked('roles', /api_users/)
  end

  it "should have a groups hyperlink" do
    expect(@links).to be_hyperlinked('groups', /api_users/)
  end

  it "should have a rights hyperlink" do
    expect(@links).to be_hyperlinked('rights', /api_users/)
  end

  it "should have a connect hyperlink" do
    expect(@links).to be_hyperlinked('connect', /api_users/)
  end

  it "should have a creator hyperlink" do
    expect(@links).to be_hyperlinked('creator', /api_users/)
  end

  it "should have a updater hyperlink" do
    expect(@links).to be_hyperlinked('updater', /api_users/)
  end


  it "should have a username" do
    expect(@u['username']).to be_a String
  end

  it "should have a real name" do
    expect(@u['real_name']).to be_a String
  end

  it "should not expose the hashed password" do
    expect(@u['password_hash']).to eq(nil)
  end

  it "should not expose the salt" do
    expect(@u['password_salt']).to eq(nil)
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

  it "should have an email field" do
    expect(@u['email']).to be_a String
  end

  it "should have an authentication_duration" do
    expect(@u['authentication_duration']).to be_an Integer
  end

  it "should have a login_blocked boolean" do
    expect(@u['login_blocked']).to eq(false)
  end

  it "should have a login_blocked_reason" do
    expect(@u['login_blocked_reason']).to eq(nil)
  end

  it "should have a indestructible boolean" do
    expect(@u['indestructible']).to eq(true)
  end

end
