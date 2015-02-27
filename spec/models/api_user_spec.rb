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
      expect(create(:api_user, username: "Peter").username).to eq("Peter")
    end

    it "should require the user name to be present" do
      expect(build(:api_user, username: nil)).not_to be_valid
      expect(build(:api_user, username: "")).not_to be_valid
      expect(build(:api_user, username: " ")).not_to be_valid
    end

    it "should require the username to be unique" do
      create(:api_user, username: "alban_berg")
      expect { create(:api_user, username: "alban_berg") }.
        to raise_exception # ActiveRecord::RecordNotUnique
    end

    it "should require the username to use alphanumeric characters plus ., -, @, and _" do
      expect(build(:api_user, username: "x")).not_to be_valid
      expect(build(:api_user, username: "xx")).to be_valid
      expect(build(:api_user, username: "FOO")).to be_valid
      expect(build(:api_user, username: "_foo")).to be_valid
      expect(build(:api_user, username: "9monkeys")).to be_valid
      expect(build(:api_user, username: "foo-Bar")).to be_valid
      expect(build(:api_user, username: "foo-bar2")).to be_valid
      expect(build(:api_user, username: "foo_BAR_2")).to be_valid
      expect(build(:api_user, username: "----___--__--")).to be_valid
      expect(build(:api_user, username: "..")).to be_valid
      expect(build(:api_user, username: "@@")).to be_valid
      expect(build(:api_user, username: "someone@example.com")).to be_valid
      expect(build(:api_user, username: "_Some-One@an.Example.com")).to be_valid
      expect(build(:api_user, username: "foo bar")).not_to be_valid
      expect(build(:api_user, username: "someone#hey@example.com")).not_to be_valid
      expect(build(:api_user, username: "someone!hey@example.com")).not_to be_valid
   end
  
  
    it "should have a hashed password" do
      expect(create(:api_user, password_hash: "gibberish").password_hash).to eq("gibberish")
    end

    it "should have a password salt" do
      expect(create(:api_user, password_salt: "NaCl-gibberish").password_salt).to eq("NaCl-gibberish")
    end

    it "should have a method to set the hashed password from the salt and a new plain text password" do
      u = create(:api_user)
      hash = u.password_hash
      u.password = "some-new-password"
      expect(hash).not_to eq(u.password_hash)
    end
  
    it "should return true from #authenticates? when there is a password match" do
      u = create :api_user, username: "myuser", password: "mypassword"
      expect(u.authenticates?("mypassword")).to eq(true)
    end

    it "should return false from #authenticates? when there is a password mismatch" do
      u = create :api_user, username: "myuser", password: "mypassword"
      expect(u.authenticates?("wrong")).to eq(false)
    end

    it "should have a real_name defaulting to the empty string" do
      expect(create(:api_user, real_name: "Herr D").real_name).to eq("Herr D")
      expect(create(:api_user).real_name).to eq("")
    end


    it "should have a creation time" do
      expect(create(:api_user).created_at).to be_a Time
    end

    it "should have an update time" do
      expect(create(:api_user).updated_at).to be_a Time
    end
  

    it "should have an email address" do
      expect(create(:api_user).email).to be_a String
    end

    it "should require a valid email address" do
      expect(build(:api_user, email: "john@@doe")).not_to be_valid
    end

    it "should not consider email addresses with names valid" do
      expect(build(:api_user, email: "John Doe <john@doe.com>")).not_to be_valid
    end


    it "should have a Authentication duration" do
      expect(create(:api_user).authentication_duration).to be_an Integer
    end

    it "should require the authentication_duration to be an integer > 0" do
      expect(build(:api_user, authentication_duration: 1)).to be_valid
      expect(build(:api_user, authentication_duration: 0)).not_to be_valid
      expect(build(:api_user, authentication_duration: -1)).not_to be_valid
      expect(build(:api_user, authentication_duration: 123.456)).not_to be_valid
    end

    it "should default the authentication_duration to 30 minutes" do
      expect(create(:api_user).authentication_duration).to eq(30.minutes)
    end


    it "should have a login_blocked boolean" do
      expect(build(:api_user).login_blocked).to eq(false)
      expect(build(:api_user, login_blocked: true).login_blocked).to eq(true)
    end

    it "should have a login_blocked_reason string" do
      expect(create(:api_user).login_blocked_reason).to eq(nil)
      expect(create(:api_user, login_blocked_reason: "Woo hoo").login_blocked_reason).to eq("Woo hoo")
    end


    it "should have an indestructible flag" do
      expect(create(:api_user).indestructible).to eq(false)
      expect(create(:api_user, indestructible: true).indestructible).to eq(true)
    end
  end

  
  describe "class method find_by_credentials" do

    it "should return an api_user given their correct credentials" do
      user = create :api_user, username: 'zizek', password: 'stalin'
      expect(ApiUser.find_by_credentials('zizek', 'stalin')).to eq(user)
    end

    it "should return false when the credentials don't match" do
      user = create :api_user, username: 'zizek', password: 'stalin'
      expect(ApiUser.find_by_credentials('zizek', 'wrong')).to eq(false)
    end

    it "should return nil when no such user exists" do
      expect(ApiUser.find_by_credentials('zizek', 'stalin')).to eq(nil)
    end
    
    it "should not touch the DB when credentials are empty" do
      expect(ApiUser).not_to receive(:find_by_username)
      ApiUser.find_by_credentials('', '')
    end
    
    it "should touch the DB when credentials are non-empty" do
      expect(ApiUser).to receive(:find_by_username)
      ApiUser.find_by_credentials('foo', 'bar')
    end
    
  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :api_user
    end
    
    
    it "should include groups HABTM" do
      expect(@my.groups).to eq([])
      @u = create :group
      @my.groups << @u
      expect(@my.groups).to eq([@u])
      expect(@u.api_users).to eq([@my])
    end
    
    it "should add and remove groups correctly" do
      @my.groups << (@x = create :group)
      @my.groups << create(:group)
      expect(@my.groups.size).to eq(2)
      @x.destroy
      @my.reload
      expect(@my.groups.size).to eq(1)
    end
    
        
    it "should include roles HABTM" do
      expect(@my.roles).to eq([])
      @r = create :role
      @my.roles << @r
      expect(@my.roles).to eq([@r])
      expect(@r.api_users).to eq([@my])
    end
    
    it "should add and remove roles correctly" do
      @my.roles << (@x = create :role)
      @my.roles << create(:role)
      expect(@my.roles.size).to eq(2)
      @x.destroy
      @my.reload
      expect(@my.roles.size).to eq(1)
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
        expect(result.sort_by(&:id)).to eq([@right1, @right2, @right3, @right4, @right5, @right6].sort_by(&:id))
      end

      it "should return exactly one right given a function which always returns true" do
        u = create :api_user
        u.roles << @role1
        u.roles << @role2
        u.groups << @group1
        u.groups << @group2
        result = []
        u.map_rights(lambda { |right| result << right; true })
        expect(result.length).to eq(1)
      end

      it "should return three rights when queried for the foo app (one is a wildcard)" do
        u = create :api_user
        u.roles << @role1
        u.roles << @role2
        u.groups << @group1
        u.groups << @group2
        result = []
        u.map_rights(lambda { |right| result << right; false }, app: "foo")
        expect(result.length).to eq(3)
        expect(result.sort_by(&:id)).to eq([@right1, @right3, @right4].sort_by(&:id))
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
        expect(ix.length).to eq(3)
        expect(ix[0]).to be_an ApiUser
      end
    
      it "should allow matches on name" do
        expect(ApiUser.collection(username: 'NOWAI').length).to eq(0)
        expect(ApiUser.collection(username: 'bar').length).to eq(1)
        expect(ApiUser.collection(username: 'baz').length).to eq(1)
      end
      
      it "should allow matches on real_name" do
        expect(ApiUser.collection(real_name: 'NOWAI').length).to eq(0)
        expect(ApiUser.collection(real_name: 'The Bar service').length).to eq(1)
        expect(ApiUser.collection(real_name: 'baz').length).to eq(0)
      end
      
      it "should allow matches on email" do
        expect(ApiUser.collection(email: 'NOWAI').length).to eq(0)
        expect(ApiUser.collection(email: 'barmail@example.com').length).to eq(1)
        expect(ApiUser.collection(email: 'example.com').length).to eq(0)
      end
      
      it "should allow searches on email" do
        expect(ApiUser.collection(search: 'example.com').length).to eq(2)
        expect(ApiUser.collection(search: '@').length).to eq(3)
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        expect(ApiUser.collection(username: 'bar', aardvark: 12).length).to eq(1)
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
      expect(@ua).to be_an ApiUserShadow
    end


    it "should copy the api_user_id when created" do
      expect(@ua.api_user_id).to eq(@u.id)
    end

    it "should copy the password_hash when created" do
      expect(@ua.password_hash).to eq(@u.password_hash)
    end

    it "should copy the password_salt when created" do
      expect(@ua.password_salt).to eq(@u.password_salt)
    end

    it "should copy the authentication_duration when created" do
      expect(@ua.authentication_duration).to eq(@u.authentication_duration)
    end

    it "should copy the login_blocked when created" do
      expect(@ua.login_blocked).to eq(@u.login_blocked)
    end

    it "should copy the login_blocked_reason when created" do
      expect(@ua.login_blocked_reason).to eq(@u.login_blocked_reason)
    end


    it "should copy the password_hash when updated" do
      @u.password_hash = "new_value"
      @u.save!
      @ua = ApiUserShadow.find_by_key("the_user", consistent: true)
      expect(@ua.password_hash).to eq("new_value")
    end

    it "should copy the password_salt when updated" do
      @u.password_salt = "new_value"
      @u.save!
      @ua = ApiUserShadow.find_by_key("the_user", consistent: true)
      expect(@ua.password_salt).to eq("new_value")
    end

    it "should copy the authentication_duration when updated" do
      @u.authentication_duration = 9999
      @u.save!
      @ua = ApiUserShadow.find_by_key("the_user", consistent: true)
      expect(@ua.authentication_duration).to eq(9999)
    end

    it "should copy the login_blocked when updated" do
      @u.login_blocked = false
      @u.save!
      @ua = ApiUserShadow.find_by_key("the_user", consistent: true)
      expect(@ua.login_blocked).to eq(false)
    end

    it "should copy the login_blocked_reason when updated" do
      @u.login_blocked_reason = nil
      @u.save!
      @ua = ApiUserShadow.find_by_key("the_user", consistent: true)
      expect(@ua.login_blocked_reason).to eq("")
    end


    it "should be deleted whenever the ApiUser is deleted" do
      @u.destroy
      expect(ApiUserShadow.find_by_key("the_user", consistent: true)).to eq(nil)
    end


    it "should be reachable by #api_user_shadow" do
      expect(@u.api_user_shadow).to eq(@ua)
    end


    it "#api_user_shadow should be cached" do
      expect(ApiUserShadow).to receive(:find).with(@u.username).once.and_return(@ua)
      expect(@u.api_user_shadow).to eq(@ua)
      expect(@u.api_user_shadow).to eq(@ua)
    end


    it "should be deleted and recreated whenever the username changes" do
      @u.username = "the_renamed_user"
      @u.save!
      expect(ApiUserShadow.find_by_key("the_user", consistent: true)).to eq(nil)
      expect(ApiUserShadow.find_by_key("the_renamed_user", consistent: true)).to be_an ApiUserShadow
    end

  end
  
end
