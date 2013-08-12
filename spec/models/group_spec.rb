# == Schema Information
#
# Table name: groups
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  description  :string(255)      default(""), not null
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  created_by   :integer          default(0), not null
#  updated_by   :integer          default(0), not null
#

require 'spec_helper'

describe Group do
  
  describe "attributes" do
    
    it "should include a name" do
      create(:group, name: "A Group").name.should == "A Group"
    end
    
    it "should include a description" do
      create(:group, name: "glurg", description: "A group description").description.should == "A group description"
    end
    
    it "should include a lock_version" do
      create(:group, lock_version: 24).lock_version.should == 24
    end
    
  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :group
    end
        
    
    it "should include api_users HABTM" do
      @my.api_users.should == []
      @u = create :api_user
      @my.api_users << @u
      @my.api_users.should == [@u]
      @u.groups.should == [@my]
    end
    
    it "should add and remove api_users correctly" do
      @my.api_users << (@x = create :api_user)
      @my.api_users << create(:api_user)
      @my.api_users.size.should == 2
      @x.destroy
      @my.reload
      @my.api_users.size.should == 1
    end
        
        
    it "should include roles HABTM" do
      @my.roles.should == []
      @r = create :role
      @my.roles << @r
      @my.roles.should == [@r]
      @r.groups.should == [@my]
    end
    
    it "should add and remove roles correctly" do
      @my.roles << (@x = create :role)
      @my.roles << create(:role)
      @my.roles.size.should == 2
      @x.destroy
      @my.reload
      @my.roles.size.should == 1
    end

        
    it "should include rights HABTM" do
      @my.rights.should == []
      @r = create :right
      @my.rights << @r
      @my.rights.should == [@r]
      @r.groups.should == [@my]
    end

    it "should add and remove rights correctly" do
      @my.rights << (@x = create :right)
      @my.rights << create(:right)
      @my.rights.size.should == 2
      @x.destroy
      @my.reload
      @my.rights.size.should == 1
    end
        
  end
  

  describe "search" do
    describe ".index_only" do
      it "should return an array of permitted search query args" do
        Group.index_only.should be_an Array
      end
    end
  
    describe ".index" do
    
      before :each do
        create :group, name: 'Admins', description: "For system administrators"
        create :group, name: 'Webshop', description: "For everyone involved in ecommerce"
        create :group, name: 'Management', description: "Suits"
      end

    
      it "should return an array of Group instances" do
        ix = Group.index
        ix.length.should == 3
        ix[0].should be_a Group
      end
    
      it "should allow matches on name" do
        Group.collection(name: 'NOWAI').length.should == 0
        Group.collection(name: 'Webshop').length.should == 1
        Group.collection(name: 'Management').length.should == 1
      end
      
      it "should allow searches on description" do
        Group.collection(search: 'For').length.should == 2
        Group.collection(search: 'i').length.should == 3
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        Group.collection(name: 'Admins', aardvark: 12).length.should == 1
      end
        
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
    end


    it "should obtain the correct all_rights when there are duplicates between roles" do
      g = create :group        # 1, 2; 2, 3, 4 => [1, 2, 3, 4]
      g.roles << @role1
      g.roles << @role2
      g.all_rights.sort_by(&:id).should ==
        [@right1, @right2, @right3, @right4].sort_by(&:id)
    end

    it "should obtain the correct all_rights when there are duplicates between roles and rights" do
      g = create :group        # 1, 2; 1; 6 => [1, 2, 6]
      g.roles << @role1
      g.rights << @right1
      g.rights << @right6
      g.all_rights.sort_by(&:id).should ==
        [@right1, @right2, @right6].sort_by(&:id)
    end

  end


end
