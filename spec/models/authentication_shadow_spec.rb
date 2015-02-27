require 'spec_helper'

describe AuthenticationShadow do

  it "should be a DynamoDB table" do
    expect(AuthenticationShadow.superclass).to eq(OceanDynamo::Table)
  end

  it "should have the token as its hash key" do
    expect(AuthenticationShadow.table_hash_key).to eq(:token)
  end
   
  it "should not use a range key" do
    expect(AuthenticationShadow.table_range_key).to eq(nil)
  end

  it "should not use timestamps" do
    expect(AuthenticationShadow.timestamp_attributes).to eq(nil)
  end
 
  it "should not use optimistic locking" do
    expect(AuthenticationShadow.lock_attribute).to eq(false)
  end
 
   

  it "should have an authorisation token string" do
    expect(AuthenticationShadow.new(token: "abc").token).to eq("abc")
  end
  
  it "should have a max age in seconds" do
    expect(AuthenticationShadow.new(max_age: 12345).max_age).to eq(12345)
  end
  
  it "should have a creation time" do
    expect(AuthenticationShadow.new(created_at: Time.now.utc).created_at).to be_a Time
  end

  it "should have an expiration time" do
    expect(AuthenticationShadow.new(expires_at: 1.hour.from_now.utc).expires_at).to be_a Time
  end

  it "should have an ApiUser id" do
    expect(AuthenticationShadow.new(api_user_id: 666).api_user_id).to eq(666)
  end

  it "should belong to an ApiUser" do
  	the_api_user = create :api_user
    expect(AuthenticationShadow.new(api_user_id: the_api_user.id).api_user).to eq(the_api_user)
  end

end
