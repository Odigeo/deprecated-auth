require 'spec_helper'

describe AuthenticationShadow do

  it "should be a DynamoDB table" do
    AuthenticationShadow.superclass.should == OceanDynamo::Table
  end

  it "should have the token as its hash key" do
    AuthenticationShadow.table_hash_key.should == :token
  end
   
  it "should not use a range key" do
    AuthenticationShadow.table_range_key.should == nil
  end

  it "should not use timestamps" do
    AuthenticationShadow.timestamp_attributes.should == nil
  end
 
  it "should not use optimistic locking" do
    AuthenticationShadow.lock_attribute.should == false
  end
 
   

  it "should have an authorisation token string" do
    AuthenticationShadow.new(token: "abc").token.should == "abc"
  end
  
  it "should have a max age in seconds" do
    AuthenticationShadow.new(max_age: 12345).max_age.should == 12345
  end
  
  it "should have a creation time" do
    AuthenticationShadow.new(created_at: Time.now.utc).created_at.should be_a Time
  end

  it "should have an expiration time" do
    AuthenticationShadow.new(expires_at: 1.hour.from_now.utc).expires_at.should be_a Time
  end

  it "should have an ApiUser id" do
    AuthenticationShadow.new(api_user_id: 666).api_user_id.should == 666
  end

  it "should belong to an ApiUser" do
  	the_api_user = create :api_user
    AuthenticationShadow.new(api_user_id: the_api_user.id).api_user.should == the_api_user
  end

end
