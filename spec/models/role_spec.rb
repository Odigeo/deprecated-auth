# == Schema Information
#
# Table name: roles
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  description        :string(255)      default(""), not null
#  lock_version       :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by         :integer          default(0), not null
#  updated_by         :integer          default(0), not null
#  indestructible     :boolean          default(FALSE), not null
#  documentation_href :string(255)
#
# Indexes
#
#  index_roles_on_created_by  (created_by)
#  index_roles_on_name        (name) UNIQUE
#  index_roles_on_updated_at  (updated_at)
#  index_roles_on_updated_by  (updated_by)
#

require 'spec_helper'


describe Role do
  
  describe "attributes" do
    
    it "should include a name" do
      create(:role, name: "A Role").name.should == "A Role"
    end
    
    it "should include a description" do
      create(:role, description: "A role description").description.should == "A role description"
    end
    
    it "should include a documentation_href" do
      create(:role, documentation_href: "http://wiki.example.com/foo").documentation_href.should == "http://wiki.example.com/foo"
    end

    it "should include a lock_version" do
      create(:role, lock_version: 24).lock_version.should == 24
    end
    
  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :role
    end
    
    
    it "should include api_users HABTM" do
      @my.api_users.should == []
      @u = create :api_user
      @my.api_users << @u
      @my.api_users.should == [@u]
      @u.roles.should == [@my]
    end
        
    it "should add and remove api_users correctly" do
      @my.api_users << (@x = create :api_user)
      @my.api_users << create(:api_user)
      @my.api_users.size.should == 2
      @x.destroy
      @my.reload
      @my.api_users.size.should == 1
    end


    it "should include groups HABTM" do
      @my.groups.should == []
      @r = create :group
      @my.groups << @r
      @my.groups.should == [@r]
      @r.roles.should == [@my]
    end
    
    it "should add and remove groups correctly" do
      @my.groups << (@x = create :group)
      @my.groups << create(:group)
      @my.groups.size.should == 2
      @x.destroy
      @my.reload
      @my.groups.size.should == 1
    end
    
        
    it "should include rights HABTM" do
      @my.rights.should == []
      @r = create :right
      @my.rights << @r
      @my.rights.should == [@r]
      @r.roles.should == [@my]
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
  
    describe ".collection" do
    
      before :each do
        create :role, name: 'System Administrator', description: "A system administrator"
        create :role, name: 'Webshop Designer', description: "Software and visuals"
        create :role, name: 'Accountant', description: "Manages our wages"
      end
    
      it "should return an array of Role instances" do
        ix = Role.collection
        ix.length.should == 3
        ix[0].should be_a Role
      end
    
      it "should allow matches on name" do
        Role.collection(name: 'NOWAI').length.should == 0
        Role.collection(name: 'Webshop Designer').length.should == 1
        Role.collection(name: 'Accountant').length.should == 1
      end
      
      it "should allow searches on description" do
        Role.collection(search: 'wa').length.should == 2
        Role.collection(search: 'e').length.should == 3
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        Role.collection(name: 'System Administrator', aardvark: 12).length.should == 1
      end
        
    end
  end

end
