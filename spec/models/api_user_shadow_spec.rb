require 'spec_helper'

describe ApiUserShadow do
  
  it "should be a DynamoDB table" do
    ApiUserShadow.superclass.should == OceanDynamo::Table
  end

  it "should have a username as its hash key" do
    ApiUserShadow.table_hash_key.should == :username
  end

  it "should not use a range key" do
    ApiUserShadow.table_range_key.should == nil
  end

  it "should require the username to be present" do
    ApiUserShadow.new(username: nil).should_not be_valid
  end

  it "should require the api_user_id to be present" do
    ApiUserShadow.new(api_user_id: nil).should_not be_valid
  end

  it "should have a hashed password" do
    ApiUserShadow.new(password_hash: "gibberish").password_hash.should == "gibberish"
  end

  it "should have a password salt" do
    ApiUserShadow.new(password_salt: "NaCl-gibberish").password_salt.should == "NaCl-gibberish"
  end

  it "should have a Authentication duration" do
    ApiUserShadow.new(authentication_duration: 12345).authentication_duration.should == 12345
  end

  it "should have a login_blocked boolean" do
    ApiUserShadow.new.login_blocked.should == false
    ApiUserShadow.new(login_blocked: true).login_blocked.should == true
  end

  it "should have a login_blocked_reason string" do
    ApiUserShadow.new.login_blocked_reason.should == ""
    ApiUserShadow.new(login_blocked_reason: "Woo hoo").login_blocked_reason.should == "Woo hoo"
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
    u.authenticates?("mypassword").should == true
    s.authenticates?("mypassword").should == true
  end

  it "should return false from #authenticates? when there is a password mismatch" do
    u = create :api_user, username: "myuser", password: "mypassword"
    s = ApiUserShadow.find("myuser", consistent: true)
    u.authenticates?("wrong").should == false
    s.authenticates?("wrong").should == false
  end

  it "should return an ApiUserShadow from #find_by_credentials when the credentials match" do
    create :api_user, username: "myuser", password: "mypassword"
    ApiUserShadow.find_by_credentials("myuser", "mypassword").should be_an ApiUserShadow
  end

  it "should return nil from #find_by_credentials when the credentials don't match" do
    create :api_user, username: "myuser", password: "mypassword"
    ApiUserShadow.find_by_credentials("myuser", "wrong").should == false
    ApiUserShadow.find_by_credentials("some_other_user", "mypassword").should == false
  end


  it "should have a #latest_authentication method" do
    u = create :api_user, username: "myuser"
    a1 = create :authentication, api_user: u, expires_at: 1.hour.from_now.utc
    a2 = create :authentication, api_user: u, expires_at: 2.hour.from_now.utc
    a3 = create :authentication, api_user: u, expires_at: 3.hour.from_now.utc
    s = ApiUserShadow.find("myuser", consistent: true)
    s.latest_authentication.expires_at.to_i.should == a3.expires_at.to_i
  end


end
