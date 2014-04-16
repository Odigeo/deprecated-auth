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
    Authentication.superclass.should == OceanDynamo::Table
  end

  it "should use the username as its hash key" do
    Authentication.table_hash_key.should == :username
  end
   
  it "should use expires_at as the range key" do
    Authentication.table_range_key.should == :expires_at
  end

      
  it "should be instantiatable" do
    create :authentication
  end
  
  it "should have an authorisation token string" do
    create(:authentication).token.should be_a String
  end
  
  it "should have a max age in seconds" do
    create(:authentication).max_age.should be_an Integer
  end
  
  it "should have a creation time" do
    create(:authentication).created_at.should be_a Time
  end

  it "should have an expiration time" do
    create(:authentication).expires_at.should be_a Time
  end
  
  it "should have its expiration time set in relation to the max age" do
    auth = create(:authentication)
    (auth.expires_at - auth.created_at).to_i.should == auth.max_age
  end


  it "should belong to an ApiUser" do
    create(:authentication).api_user.should be_an ApiUser
  end

  
  it "#new_token should return a fresh string token, 43 characters long" do
    Authentication.new_token.should be_a String
    Authentication.new_token.size.should == 43
  end
  
  it "#active? should be true if it's not expired" do
    create(:authentication, :max_age => 1.hour).active?.should be_true
  end

  it "#expired? should be false if it's not expired" do
    create(:authentication, :max_age => 1.hour).expired?.should be_false
  end
  
  it "#seconds_remaining should give the time until expiration" do
    max_age = 30.seconds
    created_at = Time.now.utc
    expires_at = created_at + max_age
    create(:authentication, :max_age => max_age, :created_at => created_at, 
           :expires_at => expires_at).seconds_remaining.should <= 30
  end

  it "#seconds_remaining should return 0 if expired" do
    create(:authentication, :expires_at => 1.year.ago.utc).seconds_remaining.should == 0
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
      @authentication.authorized?("foo", "bars", "self", "GET", "*", "*").should be_false
    end

    it "should be true if the ApiUser has a matching wildcard Right" do
      @role.rights << create(:right, resource: @resource, hyperlink: '*', verb: '*', app: '*', context: '*')
      @authentication.authorized?("foo", "bars", "self", "GET", "*", "*").should be_true
    end

    it "should be true if the ApiUser has a matching non-wildcard Right" do
      @role.rights << create(:right, resource: @resource, hyperlink: 'self', verb: 'GET', app: 'ze_app', context: 'ze_context')
      @authentication.authorized?("foo", "bars", "self", "GET", "ze_app", "ze_context").should be_true
    end

    it "should be false if the ApiUser has a non-matching non-wildcard Right" do
      @role.rights << create(:right, resource: @resource, hyperlink: 'self', verb: 'GET', app: 'blah', context: '*')
      @authentication.authorized?("foo", "bars", "self", "DELETE", "ze_app", "ze_context").should be_false
    end

    it "should return app/context pairs if the app and context don't match for */* matches but there are matching app/context rights" do
      @role.rights << create(:right, resource: @resource, hyperlink: 'self', verb: 'GET', app: 'ze_app', context: 'ze_context')
      @role.rights << create(:right, resource: @resource, hyperlink: 'self', verb: 'GET', app: 'anozer', context: '*')
      @role.rights << create(:right, resource: @resource, hyperlink: 'self', verb: 'PUT', app: '*', context: '*')
      @role.rights << create(:right, resource: @resource, hyperlink: 'quux', verb: 'GET', app: '*', context: '*')
      @authentication.authorized?("foo", "bars", "self", "GET", "*", "*").
        should == [{"app"=>"ze_app", "context"=>"ze_context"}, 
                   {"app"=>"anozer", "context"=>"*"}]
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
      @au.should be_an Authentication
      @as.should be_an AuthenticationShadow
    end


    it "should copy created_at when created" do
      @as.created_at.to_s.should == @au.created_at.to_s
    end

    it "should copy expires_at when created" do
      @as.expires_at.to_s.should == @au.expires_at.to_s
    end

    it "should copy the token when created" do
      @as.token.should == @au.token
    end

    it "should copy max_age when created" do
      @as.max_age.should == @au.max_age
    end

    it "should copy api_user_id when created" do
      @as.api_user_id.should == @au.api_user_id
    end


    it "should copy created_at when updated" do
      t = 1.day.ago.utc
      @au.created_at = t
      @au.save!
      @as = AuthenticationShadow.find("the_token", consistent: true)
      (@as.created_at - t).to_i.should == 0
    end

    it "should copy expires_at when updated" do
      t = 1.week.from_now.utc
      @au.expires_at = t
      @au.save!
      @as = AuthenticationShadow.find("the_token", consistent: true)
      (@as.expires_at - t).to_i.should == 0
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
      @as.max_age.should == 98765
    end

    it "should copy api_user_id when updated" do
      @au.api_user_id = 22222
      @au.save!
      @as = AuthenticationShadow.find("the_token", consistent: true)
      @as.api_user_id.should == 22222
    end


    it "should be deleted whenever the Authentication is deleted" do
      @au.destroy
      AuthenticationShadow.find_by_key("the_token", consistent: true).should == nil
    end

    it "should be deleted whenever the ApiUser is deleted" do
      @u.destroy
      AuthenticationShadow.find_by_key("the_token", consistent: true).should == nil
    end


    it "should be reachable by #authentication_shadow" do
      @au.authentication_shadow.should == @as
    end

    it "should be able to retrieve its authentication" do
      asau = @as.authentication
      asau.username.should == @au.username
      (asau.expires_at - @au.expires_at).to_i.should == 0
    end


  end

end
