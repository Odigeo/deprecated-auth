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
#  index_authentications_on_expires_at  (expires_at)
#  index_authentications_on_token       (token) UNIQUE
#  index_authentications_per_user       (api_user_id,created_at,expires_at)
#

require 'spec_helper'

describe Authentication do
      
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

  it "should have a scope which returns only active authentications" do
    create(:authentication)
    create(:authentication)
    create(:authentication, created_at: (2.years.ago - 30.minutes).utc, expires_at: 2.years.ago.utc)
    create(:authentication, created_at: (1.year.ago - 30.minutes).utc, expires_at: 1.year.ago.utc)
    create(:authentication)
    Authentication.count.should == 5
    Authentication.active.count.should == 3
    Authentication.destroy_all
  end
  

  describe "search" do
  
    describe ".collection" do
    
      before :each do
        @r1 = create :authentication, token: "foofoofoo"
        @r2 = create :authentication, token: "barfoobar"
        @r3 = create :authentication, token: "barbazzuul"
      end
      
    
      it "should return an array of Authentication instances" do
        ix = Authentication.collection
        ix.length.should == 3
        ix[0].should be_an Authentication
      end
    
      it "should allow matches on token" do
        Authentication.collection(token: 'NOWAI').length.should == 0
        Authentication.collection(token: @r1.token).length.should == 1
        Authentication.collection(token: @r2.token).length.should == 1
      end
      
      it "should not allow searches" do
        Authentication.collection(search: 'foo').length.should == 0
        Authentication.collection(search: 'zuul').length.should == 0
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        Authentication.collection(token: @r3.token, aardvark: 12).length.should == 1
      end
        
    end
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
  
end
