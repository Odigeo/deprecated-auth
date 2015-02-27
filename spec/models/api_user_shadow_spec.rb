require 'spec_helper'

describe ApiUserShadow do
  
  it "should be a DynamoDB table" do
    expect(ApiUserShadow.superclass).to eq(OceanDynamo::Table)
  end

  it "should have a username as its hash key" do
    expect(ApiUserShadow.table_hash_key).to eq(:username)
  end

  it "should not use a range key" do
    expect(ApiUserShadow.table_range_key).to eq(nil)
  end

  it "should require the username to be present" do
    expect(ApiUserShadow.new(username: nil)).not_to be_valid
  end

  it "should require the api_user_id to be present" do
    expect(ApiUserShadow.new(api_user_id: nil)).not_to be_valid
  end

  it "should have a hashed password" do
    expect(ApiUserShadow.new(password_hash: "gibberish").password_hash).to eq("gibberish")
  end

  it "should have a password salt" do
    expect(ApiUserShadow.new(password_salt: "NaCl-gibberish").password_salt).to eq("NaCl-gibberish")
  end

  it "should have a Authentication duration" do
    expect(ApiUserShadow.new(authentication_duration: 12345).authentication_duration).to eq(12345)
  end

  it "should have a login_blocked boolean" do
    expect(ApiUserShadow.new.login_blocked).to eq(false)
    expect(ApiUserShadow.new(login_blocked: true).login_blocked).to eq(true)
  end

  it "should have a login_blocked_reason string" do
    expect(ApiUserShadow.new.login_blocked_reason).to eq("")
    expect(ApiUserShadow.new(login_blocked_reason: "Woo hoo").login_blocked_reason).to eq("Woo hoo")
  end

  it "should not have a created_at datetime" do
    expect { ApiUserShadow.new.created_at }.to raise_error
  end

  it "should not have an updated_at datetime" do
    expect { ApiUserShadow.new.updated_at }.to raise_error
  end

  it "should not have a lock_version" do
    expect { ApiUserShadow.new.lock_version }.to raise_error
  end


  it "should return true from #authenticates? when there is a password match" do
    u = create :api_user, username: "myuser", password: "mypassword"
    s = ApiUserShadow.find("myuser", consistent: true)
    expect(u.authenticates?("mypassword")).to eq(true)
    expect(s.authenticates?("mypassword")).to eq(true)
  end

  it "should return false from #authenticates? when there is a password mismatch" do
    u = create :api_user, username: "myuser", password: "mypassword"
    s = ApiUserShadow.find("myuser", consistent: true)
    expect(u.authenticates?("wrong")).to eq(false)
    expect(s.authenticates?("wrong")).to eq(false)
  end

  it "should return an ApiUserShadow from #find_by_credentials when the credentials match" do
    create :api_user, username: "myuser", password: "mypassword"
    expect(ApiUserShadow.find_by_credentials("myuser", "mypassword")).to be_an ApiUserShadow
  end

  it "should return nil from #find_by_credentials when the credentials don't match" do
    create :api_user, username: "myuser", password: "mypassword"
    expect(ApiUserShadow.find_by_credentials("myuser", "wrong")).to eq(false)
    expect(ApiUserShadow.find_by_credentials("some_other_user", "mypassword")).to eq(false)
  end


  it "should have a #latest_authentication method" do
    u = create :api_user, username: "myuser"
    a1 = create :authentication, api_user: u, expires_at: 1.hour.from_now.utc
    a2 = create :authentication, api_user: u, expires_at: 2.hour.from_now.utc
    a3 = create :authentication, api_user: u, expires_at: 3.hour.from_now.utc
    s = ApiUserShadow.find("myuser", consistent: true)
    expect(s.latest_authentication.expires_at.to_i).to eq(a3.expires_at.to_i)
  end


end
