# == Schema Information
#
# Table name: api_users
#
#  id                        :integer          not null, primary key
#  username                  :string(255)      not null
#  password_hash             :string(255)      not null
#  password_salt             :string(255)      not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  real_name                 :string(255)      default("")
#  lock_version              :integer          default(0), not null
#  email                     :string(255)      default(""), not null
#  created_by                :integer          default(0), not null
#  updated_by                :integer          default(0), not null
#  authentication_duration   :integer          default(1800), not null
#  shareable_authentications :boolean          default(FALSE), not null
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

    it "should require the username to conform to /[A-Za-z][A-Za-z0-9_-]+/" do
      build(:api_user, username: "FOO").should be_valid
      build(:api_user, username: "foo-Bar").should be_valid
      build(:api_user, username: "foo-bar2").should be_valid
      build(:api_user, username: "foo_BAR_2").should be_valid
      build(:api_user, username: "A----___--__--").should be_valid
      build(:api_user, username: "xx").should be_valid
      build(:api_user, username: "x").should_not be_valid
      build(:api_user, username: "foo bar").should_not be_valid
      build(:api_user, username: "_foo").should_not be_valid
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
      u.authenticates?("mypassword").should be_true
    end

    it "should return false from #authenticates? when there is a password mismatch" do
      u = create :api_user, username: "myuser", password: "mypassword"
      u.authenticates?("wrong").should be_false
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


    it "should have a shareable_authentications boolean" do
      build(:api_user).shareable_authentications.should == false
      build(:api_user, shareable_authentications: true).shareable_authentications.should == true
      build(:api_user, shareable_authentications: "quoi?").shareable_authentications.should == false
    end

  end
  
  
  describe "class method find_by_credentials" do

    it "should return an api_user given their correct credentials" do
      user = create :api_user, username: 'zizek', password: 'stalin'
      ApiUser.find_by_credentials('zizek', 'stalin').should == user
    end

    it "should return false when the credentials don't match" do
      user = create :api_user, username: 'zizek', password: 'stalin'
      ApiUser.find_by_credentials('zizek', 'wrong').should be_false
    end

    it "should return false when no such user exists" do
      ApiUser.find_by_credentials('zizek', 'stalin').should be_false
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
  

  describe "all_rights" do

    before :each do
      @right1 = create :right
      @right2 = create :right
      @right3 = create :right
      @right4 = create :right
      @right5 = create :right
      @right6 = create :right

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


    it "should obtain the correct all_rights for duplicates within roles" do
      u = create :api_user
      u.roles << @role1
      u.roles << @role2
      u.all_rights.sort_by(&:id).should ==
        [@right1, @right2, @right3, @right4].sort_by(&:id)
    end

    it "should obtain the correct all_rights for duplicates within groups" do
      u = create :api_user
      u.groups << @group1
      u.groups << @group2
      u.all_rights.sort_by(&:id).should ==
        [@right1, @right2, @right3, @right4, @right5, @right6].sort_by(&:id)
    end

    it "should obtain the correct all_rights for duplicates between groups and roles" do
      u = create :api_user
      u.roles << @role1
      u.groups << @group1
      u.all_rights.sort_by(&:id).should ==
        [@right1, @right2, @right6].sort_by(&:id)
    end

  end

  describe "search" do
    describe ".index_only" do
      it "should return an array of permitted search query args" do
        ApiUser.index_only.should be_an Array
      end
    end
  
    describe ".index" do
    
      before :each do
        create :api_user, username: 'foo', real_name: "The Foo service", email: "foomail@example.com"
        create :api_user, username: 'bar', real_name: "The Bar service", email: "barmail@example.com"
        create :api_user, username: 'baz', real_name: "The Baz service", email: "baz@hello.org"
      end
      
    
      it "should return an array of ApiUser instances" do
        ix = ApiUser.index
        ix.length.should == 3
        ix[0].should be_an ApiUser
      end
    
      it "should allow matches on name" do
        ApiUser.index(username: 'NOWAI').length.should == 0
        ApiUser.index(username: 'bar').length.should == 1
        ApiUser.index(username: 'baz').length.should == 1
      end
      
      it "should allow matches on real_name" do
        ApiUser.index(real_name: 'NOWAI').length.should == 0
        ApiUser.index(real_name: 'The Bar service').length.should == 1
        ApiUser.index(real_name: 'baz').length.should == 0
      end
      
      it "should allow matches on email" do
        ApiUser.index(email: 'NOWAI').length.should == 0
        ApiUser.index(email: 'barmail@example.com').length.should == 1
        ApiUser.index(email: 'example.com').length.should == 0
      end
      
      it "should allow searches on email" do
        ApiUser.index({}, nil, 'example.com').length.should == 2
        ApiUser.index({}, nil, '@').length.should == 3
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        ApiUser.index(username: 'bar', aardvark: 12).length.should == 1
      end
        
    end
  end

  
end
