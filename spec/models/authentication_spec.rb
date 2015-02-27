# == Schema Information
#
# Table name: authentications
#
#  id          :integer          not null, primary key
#  token       :string(255)      not null
#  max_age     :integer          not null
#  created_at  :datetime         not null
#  expires_at  :datetime         not null
#  api_user_id :integer
#
# Indexes
#
#  index_authentications_on_api_user_id_and_expires_at  (api_user_id,expires_at)
#  index_authentications_on_expires_at                  (expires_at)
#  index_authentications_on_token                       (token) UNIQUE
#

require 'spec_helper'

describe Authentication do

  before :each do
    Authentication.delete_all
  end


  it "should be a DynamoDB table" do
    expect(Authentication.superclass).to eq(OceanDynamo::Table)
  end

  it "should use the username as its hash key" do
    expect(Authentication.table_hash_key).to eq(:username)
  end
   
  it "should use expires_at as the range key" do
    expect(Authentication.table_range_key).to eq(:expires_at)
  end

      
  it "should be instantiatable" do
    create :authentication
  end
  
  it "should have an authorisation token string" do
    expect(create(:authentication).token).to be_a String
  end
  
  it "should have a max age in seconds" do
    expect(create(:authentication).max_age).to be_an Integer
  end
  
  it "should have a creation time" do
    expect(create(:authentication).created_at).to be_a Time
  end

  it "should have an expiration time" do
    expect(create(:authentication).expires_at).to be_a Time
  end
  
  it "should have its expiration time set in relation to the max age" do
    auth = create(:authentication)
    expect((auth.expires_at - auth.created_at).to_i).to eq(auth.max_age)
  end


  it "should belong to an ApiUser" do
    expect(create(:authentication).api_user).to be_an ApiUser
  end

  
  it "#new_token should return a fresh string token, 43 characters long" do
    expect(Authentication.new_token).to be_a String
    expect(Authentication.new_token.size).to eq(43)
  end
  
  it "#active? should be true if it's not expired" do
    expect(create(:authentication, :max_age => 1.hour).active?).to eq(true)
  end

  it "#expired? should be false if it's not expired" do
    expect(create(:authentication, :max_age => 1.hour).expired?).to eq(false)
  end
  
  it "#seconds_remaining should give the time until expiration" do
    max_age = 30.seconds
    created_at = Time.now.utc
    expires_at = created_at + max_age
    expect(create(:authentication, :max_age => max_age, :created_at => created_at, 
           :expires_at => expires_at).seconds_remaining).to be <= 30
  end

  it "#seconds_remaining should return 0 if expired" do
    expect(create(:authentication, :expires_at => 1.year.ago.utc).seconds_remaining).to eq(0)
  end


  describe "#authorized?" do

    before :each do
      @api_user = create :api_user
      @role = create :role
      @service = create(:service, name: "foo")
      @resource = create(:resource, name: "bars", service: @service)
      @api_user.roles << @role
      # The @authentication
      @authentication = create(:authentication, api_user: @api_user)
    end


    it "should be false at once if the ApiUser has no Rights at all for the service and resource" do
      expect(@authentication.authorized?("foo", "bars", "self", "GET", "*", "*")).to eq(false)
    end

    it "should return the matching Right if the ApiUser has a matching wildcard Right" do
      @role.rights << create(:right, resource: @resource, hyperlink: '*', verb: '*', app: '*', context: '*')
      expect(@authentication.authorized?("foo", "bars", "self", "GET", "*", "*")).to be_a Right
    end

    it "should return the matching Right if the ApiUser has a matching non-wildcard Right" do
      @role.rights << create(:right, resource: @resource, hyperlink: 'self', verb: 'GET', app: 'ze_app', context: 'ze_context')
      expect(@authentication.authorized?("foo", "bars", "self", "GET", "ze_app", "ze_context")).to be_a Right
    end

    it "should be false if the ApiUser has a non-matching non-wildcard Right" do
      @role.rights << create(:right, resource: @resource, hyperlink: 'self', verb: 'GET', app: 'blah', context: '*')
      expect(@authentication.authorized?("foo", "bars", "self", "DELETE", "ze_app", "ze_context")).to eq(false)
    end

    it "should return app/context pairs if the app and context don't match for */* matches but there are matching app/context rights" do
      @role.rights << create(:right, resource: @resource, hyperlink: 'self', verb: 'GET', app: 'ze_app', context: 'ze_context')
      @role.rights << create(:right, resource: @resource, hyperlink: 'self', verb: 'GET', app: 'anozer', context: '*')
      @role.rights << create(:right, resource: @resource, hyperlink: 'self', verb: 'PUT', app: '*', context: '*')
      @role.rights << create(:right, resource: @resource, hyperlink: 'quux', verb: 'GET', app: '*', context: '*')
      expect(@authentication.authorized?("foo", "bars", "self", "GET", "*", "*")).
        to eq([{"app"=>"ze_app", "context"=>"ze_context"}, 
                   {"app"=>"anozer", "context"=>"*"}])
    end
  end
  

  describe "AuthenticationShadow" do
    before :each do
      AuthenticationShadow.delete_all if AuthenticationShadow.count > 0
      @u = create :api_user, username: "the_user"
      @au = create :authentication, expires_at: 1.hour.from_now.utc,
                                    token: "the_token",
                                    api_user_id: @u.id,
                                    username: @u.username,
                                    max_age: 1800,
                                    created_at: Time.now.utc
      @as = AuthenticationShadow.find("the_token", consistent: true)
    end

    it "should be created whenever the Authentication is created" do
      expect(@au).to be_an Authentication
      expect(@as).to be_an AuthenticationShadow
    end


    it "should copy created_at when created" do
      expect(@as.created_at.to_s).to eq(@au.created_at.to_s)
    end

    it "should copy expires_at when created" do
      expect(@as.expires_at.to_s).to eq(@au.expires_at.to_s)
    end

    it "should copy the token when created" do
      expect(@as.token).to eq(@au.token)
    end

    it "should copy max_age when created" do
      expect(@as.max_age).to eq(@au.max_age)
    end

    it "should copy api_user_id when created" do
      expect(@as.api_user_id).to eq(@au.api_user_id)
    end


    it "should copy created_at when updated" do
      t = 1.day.ago.utc
      @au.created_at = t
      @au.save!
      @as = AuthenticationShadow.find("the_token", consistent: true)
      expect((@as.created_at - t).to_i).to eq(0)
    end

    it "should copy expires_at when updated" do
      t = 1.week.from_now.utc
      @au.expires_at = t
      @au.save!
      @as = AuthenticationShadow.find("the_token", consistent: true)
      expect((@as.expires_at - t).to_i).to eq(0)
    end

    # it "should barf on changes to the token when updated, since it's the key" do
    #   @au.token = "BLAHONGA"
    #   @au.save!
    #   @as = AuthenticationShadow.find("BLAHONGA", consistent: true)
    #   @as.token.should == "BLAHONGA"
    # end

    it "should copy the max_age when updated" do
      @au.max_age = 98765
      @au.save!
      @as = AuthenticationShadow.find("the_token", consistent: true)
      expect(@as.max_age).to eq(98765)
    end

    it "should copy api_user_id when updated" do
      @au.api_user_id = 22222
      @au.save!
      @as = AuthenticationShadow.find("the_token", consistent: true)
      expect(@as.api_user_id).to eq(22222)
    end


    it "should be deleted whenever the Authentication is deleted" do
      @au.destroy
      expect(AuthenticationShadow.find_by_key("the_token", consistent: true)).to eq(nil)
    end

    it "should be deleted whenever the ApiUser is deleted" do
      @u.destroy
      expect(AuthenticationShadow.find_by_key("the_token", consistent: true)).to eq(nil)
    end


    it "should be reachable by #authentication_shadow" do
      expect(@au.authentication_shadow).to eq(@as)
    end

    it "should be able to retrieve its authentication" do
      asau = @as.authentication
      expect(asau.username).to eq(@au.username)
      expect((asau.expires_at - @au.expires_at).to_i).to eq(0)
    end


  end

end
