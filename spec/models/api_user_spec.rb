# == Schema Information
#
# Table name: api_users
#
#  id                      :integer          not null, primary key
#  username                :string(255)      not null
#  password_hash           :string(255)      not null
#  password_salt           :string(255)      not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  real_name               :string(255)      default("")
#  lock_version            :integer          default(0), not null
#  email                   :string(255)      default(""), not null
#  created_by              :integer          default(0), not null
#  updated_by              :integer          default(0), not null
#  authentication_duration :integer          default(1800), not null
#  login_blocked           :boolean          default(FALSE), not null
#  login_blocked_reason    :string(255)
#  indestructible          :boolean          default(FALSE), not null
#
# Indexes
#
#  index_api_users_on_created_by  (created_by)
#  index_api_users_on_updated_at  (updated_at)
#  index_api_users_on_updated_by  (updated_by)
#  index_api_users_on_username    (username) UNIQUE
#

require 'spec_helper'

describe ApiUser do
  
  describe "attributes" do
  
    it "should have a user name" do
      create(:api_user, username: "Peter").username.should == "Peter"
    end

    it "should require the user name to be present" do
      build(:api_user, username: nil).should_not be_valid
      build(:api_user, username: "").should_not be_valid
      build(:api_user, username: " ").should_not be_valid
    end

    it "should require the username to be unique" do
      create(:api_user, username: "alban_berg")
      lambda { create(:api_user, username: "alban_berg") }.
        should raise_exception # ActiveRecord::RecordNotUnique
    end

    it "should require the username to use alphanumeric characters plus ., -, @, and _" do
      build(:api_user, username: "x").should_not be_valid
      build(:api_user, username: "xx").should be_valid
      build(:api_user, username: "FOO").should be_valid
      build(:api_user, username: "_foo").should be_valid
      build(:api_user, username: "9monkeys").should be_valid
      build(:api_user, username: "foo-Bar").should be_valid
      build(:api_user, username: "foo-bar2").should be_valid
      build(:api_user, username: "foo_BAR_2").should be_valid
      build(:api_user, username: "----___--__--").should be_valid
      build(:api_user, username: "..").should be_valid
      build(:api_user, username: "@@").should be_valid
      build(:api_user, username: "someone@example.com").should be_valid
      build(:api_user, username: "_Some-One@an.Example.com").should be_valid
      build(:api_user, username: "foo bar").should_not be_valid
      build(:api_user, username: "someone#hey@example.com").should_not be_valid
      build(:api_user, username: "someone!hey@example.com").should_not be_valid
   end
  
  
    it "should have a hashed password" do
      create(:api_user, password_hash: "gibberish").password_hash.should == "gibberish"
    end

    it "should have a password salt" do
      create(:api_user, password_salt: "NaCl-gibberish").password_salt.should == "NaCl-gibberish"
    end

    it "should have a method to set the hashed password from the salt and a new plain text password" do
      u = create(:api_user)
      hash = u.password_hash
      u.password = "some-new-password"
      hash.should_not == u.password_hash
    end
  
    it "should return true from #authenticates? when there is a password match" do
      u = create :api_user, username: "myuser", password: "mypassword"
      u.authenticates?("mypassword").should == true
    end

    it "should return false from #authenticates? when there is a password mismatch" do
      u = create :api_user, username: "myuser", password: "mypassword"
      u.authenticates?("wrong").should == false
    end

    it "should have a real_name defaulting to the empty string" do
      create(:api_user, real_name: "Herr D").real_name.should == "Herr D"
      create(:api_user).real_name.should == ""
    end


    it "should have a creation time" do
      create(:api_user).created_at.should be_a Time
    end

    it "should have an update time" do
      create(:api_user).updated_at.should be_a Time
    end
  

    it "should have an email address" do
      create(:api_user).email.should be_a String
    end

    it "should require a valid email address" do
      build(:api_user, email: "john@@doe").should_not be_valid
    end

    it "should not consider email addresses with names valid" do
      build(:api_user, email: "John Doe <john@doe.com>").should_not be_valid
    end


    it "should have a Authentication duration" do
      create(:api_user).authentication_duration.should be_an Integer
    end

    it "should require the authentication_duration to be an integer > 0" do
      build(:api_user, authentication_duration: 1).should be_valid
      build(:api_user, authentication_duration: 0).should_not be_valid
      build(:api_user, authentication_duration: -1).should_not be_valid
      build(:api_user, authentication_duration: 123.456).should_not be_valid
    end

    it "should default the authentication_duration to 30 minutes" do
      create(:api_user).authentication_duration.should == 30.minutes
    end


    it "should have a login_blocked boolean" do
      build(:api_user).login_blocked.should == false
      build(:api_user, login_blocked: true).login_blocked.should == true
    end

    it "should have a login_blocked_reason string" do
      create(:api_user).login_blocked_reason.should == nil
      create(:api_user, login_blocked_reason: "Woo hoo").login_blocked_reason.should == "Woo hoo"
    end


    it "should have an indestructible flag" do
      create(:api_user).indestructible.should == false
      create(:api_user, indestructible: true).indestructible.should == true
    end
  end

  
  describe "class method find_by_credentials" do

    it "should return an api_user given their correct credentials" do
      user = create :api_user, username: 'zizek', password: 'stalin'
      ApiUser.find_by_credentials('zizek', 'stalin').should == user
    end

    it "should return false when the credentials don't match" do
      user = create :api_user, username: 'zizek', password: 'stalin'
      ApiUser.find_by_credentials('zizek', 'wrong').should == false
    end

    it "should return nil when no such user exists" do
      ApiUser.find_by_credentials('zizek', 'stalin').should == nil
    end
    
    it "should not touch the DB when credentials are empty" do
      ApiUser.should_not_receive(:find_by_username)
      ApiUser.find_by_credentials('', '')
    end
    
    it "should touch the DB when credentials are non-empty" do
      ApiUser.should_receive(:find_by_username)
      ApiUser.find_by_credentials('foo', 'bar')
    end
    
  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :api_user
    end
    
    
    it "should include groups HABTM" do
      @my.groups.should == []
      @u = create :group
      @my.groups << @u
      @my.groups.should == [@u]
      @u.api_users.should == [@my]
    end
    
    it "should add and remove groups correctly" do
      @my.groups << (@x = create :group)
      @my.groups << create(:group)
      @my.groups.size.should == 2
      @x.destroy
      @my.reload
      @my.groups.size.should == 1
    end
    
        
    it "should include roles HABTM" do
      @my.roles.should == []
      @r = create :role
      @my.roles << @r
      @my.roles.should == [@r]
      @r.api_users.should == [@my]
    end
    
    it "should add and remove roles correctly" do
      @my.roles << (@x = create :role)
      @my.roles << create(:role)
      @my.roles.size.should == 2
      @x.destroy
      @my.reload
      @my.roles.size.should == 1
    end
              
  end
  

  describe do

    before :each do
      @right1 = create :right, app: "foo", context: "quux"
      @right2 = create :right, app: "bar", context: "*"
      @right3 = create :right, app: "foo", context: "*"
      @right4 = create :right, app: "*", context: "*"
      @right5 = create :right, app: "baz", context: "zuul"
      @right6 = create :right, app: "bar", context: "zuul"

      @role1 = create :role
      @role1.rights << @right1
      @role1.rights << @right2

      @role2 = create :role
      @role2.rights << @right2
      @role2.rights << @right3
      @role2.rights << @right4

      @group1 = create :group        # [1, 2, 6]
      @group1.roles << @role1
      @group1.rights << @right1
      @group1.rights << @right6

      @group2 = create :group        # [1, 2, 3, 4, 5]
      @group2.roles << @role1
      @group2.roles << @role2
      @group2.rights << @right5
      @group2.rights << @right2
      @group2.rights << @right3
    end


    describe "map_rights" do

      it "should traverse all rights given a function which always returns false" do
        u = create :api_user
        u.roles << @role1
        u.roles << @role2
        u.groups << @group1
        u.groups << @group2
        result = []
        u.map_rights(lambda { |right| result << right; false })
        result.sort_by(&:id).should == [@right1, @right2, @right3, @right4, @right5, @right6].sort_by(&:id)
      end

      it "should return exactly one right given a function which always returns true" do
        u = create :api_user
        u.roles << @role1
        u.roles << @role2
        u.groups << @group1
        u.groups << @group2
        result = []
        u.map_rights(lambda { |right| result << right; true })
        result.length.should == 1
      end

      it "should return three rights when queried for the foo app (one is a wildcard)" do
        u = create :api_user
        u.roles << @role1
        u.roles << @role2
        u.groups << @group1
        u.groups << @group2
        result = []
        u.map_rights(lambda { |right| result << right; false }, app: "foo")
        result.length.should == 3
        result.sort_by(&:id).should == [@right1, @right3, @right4].sort_by(&:id)
      end
    end

    describe "effective_rights" do

      it "should return an array" do
        u = create :api_user
        expect(u.effective_rights).to eq []
      end

      it "should return all the rights of the user" do
        u = create :api_user
        u.groups << @group1
        expect(u.effective_rights.to_set).to eq [@right1, @right2, @right6].to_set
      end

    end
  end


  describe "search" do
  
    describe ".collection" do
    
      before :each do
        create :api_user, username: 'foo', real_name: "The Foo service", email: "foomail@example.com"
        create :api_user, username: 'bar', real_name: "The Bar service", email: "barmail@example.com"
        create :api_user, username: 'baz', real_name: "The Baz service", email: "baz@hello.org"
      end
      
    
      it "should return an array of ApiUser instances" do
        ix = ApiUser.collection
        ix.length.should == 3
        ix[0].should be_an ApiUser
      end
    
      it "should allow matches on name" do
        ApiUser.collection(username: 'NOWAI').length.should == 0
        ApiUser.collection(username: 'bar').length.should == 1
        ApiUser.collection(username: 'baz').length.should == 1
      end
      
      it "should allow matches on real_name" do
        ApiUser.collection(real_name: 'NOWAI').length.should == 0
        ApiUser.collection(real_name: 'The Bar service').length.should == 1
        ApiUser.collection(real_name: 'baz').length.should == 0
      end
      
      it "should allow matches on email" do
        ApiUser.collection(email: 'NOWAI').length.should == 0
        ApiUser.collection(email: 'barmail@example.com').length.should == 1
        ApiUser.collection(email: 'example.com').length.should == 0
      end
      
      it "should allow searches on email" do
        ApiUser.collection(search: 'example.com').length.should == 2
        ApiUser.collection(search: '@').length.should == 3
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        ApiUser.collection(username: 'bar', aardvark: 12).length.should == 1
      end
        
    end
  end


  describe "ApiUserShadow" do

    before :each do
      ApiUserShadow.delete_all
      @u = create :api_user, username: "the_user",
                             authentication_duration: 1000,
                             login_blocked: true, 
                             login_blocked_reason: "because"
      @ua = ApiUserShadow.find_by_key("the_user", consistent: true)
    end

    it "should be created whenever the ApiUser is created" do
      @ua.should be_an ApiUserShadow
    end


    it "should copy the api_user_id when created" do
      @ua.api_user_id.should == @u.id
    end

    it "should copy the password_hash when created" do
      @ua.password_hash.should == @u.password_hash
    end

    it "should copy the password_salt when created" do
      @ua.password_salt.should == @u.password_salt
    end

    it "should copy the authentication_duration when created" do
      @ua.authentication_duration.should == @u.authentication_duration
    end

    it "should copy the login_blocked when created" do
      @ua.login_blocked.should == @u.login_blocked
    end

    it "should copy the login_blocked_reason when created" do
      @ua.login_blocked_reason.should == @u.login_blocked_reason
    end


    it "should copy the password_hash when updated" do
      @u.password_hash = "new_value"
      @u.save!
      @ua = ApiUserShadow.find_by_key("the_user", consistent: true)
      @ua.password_hash.should == "new_value"
    end

    it "should copy the password_salt when updated" do
      @u.password_salt = "new_value"
      @u.save!
      @ua = ApiUserShadow.find_by_key("the_user", consistent: true)
      @ua.password_salt.should == "new_value"
    end

    it "should copy the authentication_duration when updated" do
      @u.authentication_duration = 9999
      @u.save!
      @ua = ApiUserShadow.find_by_key("the_user", consistent: true)
      @ua.authentication_duration.should == 9999
    end

    it "should copy the login_blocked when updated" do
      @u.login_blocked = false
      @u.save!
      @ua = ApiUserShadow.find_by_key("the_user", consistent: true)
      @ua.login_blocked.should == false
    end

    it "should copy the login_blocked_reason when updated" do
      @u.login_blocked_reason = nil
      @u.save!
      @ua = ApiUserShadow.find_by_key("the_user", consistent: true)
      @ua.login_blocked_reason.should == ""
    end


    it "should be deleted whenever the ApiUser is deleted" do
      @u.destroy
      ApiUserShadow.find_by_key("the_user", consistent: true).should == nil
    end


    it "should be reachable by #api_user_shadow" do
      @u.api_user_shadow.should == @ua
    end


    it "#api_user_shadow should be cached" do
      ApiUserShadow.should_receive(:find).with(@u.username).once.and_return(@ua)
      @u.api_user_shadow.should == @ua
      @u.api_user_shadow.should == @ua
    end


    it "should be deleted and recreated whenever the username changes" do
      @u.username = "the_renamed_user"
      @u.save!
      ApiUserShadow.find_by_key("the_user", consistent: true).should == nil
      ApiUserShadow.find_by_key("the_renamed_user", consistent: true).should be_an ApiUserShadow
    end

  end
  
end
