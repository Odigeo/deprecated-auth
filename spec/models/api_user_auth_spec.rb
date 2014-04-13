require 'spec_helper'

describe ApiUserAuth do
  
  it "should be a DynamoDB table" do
    ApiUserAuth.superclass.should == OceanDynamo::Table
  end

  it "should have a username as its key" do
    ApiUserAuth.table_hash_key.should == :username
  end

  it "should require the username to be present" do
    ApiUserAuth.new.should_not be_valid
  end

  it "should have a hashed password" do
    ApiUserAuth.new(password_hash: "gibberish").password_hash.should == "gibberish"
  end

  it "should have a password salt" do
    ApiUserAuth.new(password_salt: "NaCl-gibberish").password_salt.should == "NaCl-gibberish"
  end

  it "should have a Authentication duration" do
    ApiUserAuth.new(authentication_duration: 12345).authentication_duration.should == 12345
  end

  it "should have a login_blocked boolean" do
    ApiUserAuth.new.login_blocked.should == false
    ApiUserAuth.new(login_blocked: true).login_blocked.should == true
  end

  it "should have a login_blocked_reason string" do
    ApiUserAuth.new.login_blocked_reason.should == ""
    ApiUserAuth.new(login_blocked_reason: "Woo hoo").login_blocked_reason.should == "Woo hoo"
  end

  it "should not have a created_at datetime" do
    expect { ApiUserAuth.new.created_at }.to raise_error
  end

  it "should not have an updated_at datetime" do
    expect { ApiUserAuth.new.updated_at }.to raise_error
  end

  it "should not have a lock_version" do
    expect { ApiUserAuth.new.lock_version }.to raise_error
  end




end
