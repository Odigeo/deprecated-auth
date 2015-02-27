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
      expect(create(:role, name: "A Role").name).to eq("A Role")
    end
    
    it "should include a description" do
      expect(create(:role, description: "A role description").description).to eq("A role description")
    end
    
    it "should include a documentation_href" do
      expect(create(:role, documentation_href: "http://wiki.example.com/foo").documentation_href).to eq("http://wiki.example.com/foo")
    end

    it "should include a lock_version" do
      expect(create(:role, lock_version: 24).lock_version).to eq(24)
    end
    
  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :role
    end
    
    
    it "should include api_users HABTM" do
      expect(@my.api_users).to eq([])
      @u = create :api_user
      @my.api_users << @u
      expect(@my.api_users).to eq([@u])
      expect(@u.roles).to eq([@my])
    end
        
    it "should add and remove api_users correctly" do
      @my.api_users << (@x = create :api_user)
      @my.api_users << create(:api_user)
      expect(@my.api_users.size).to eq(2)
      @x.destroy
      @my.reload
      expect(@my.api_users.size).to eq(1)
    end


    it "should include groups HABTM" do
      expect(@my.groups).to eq([])
      @r = create :group
      @my.groups << @r
      expect(@my.groups).to eq([@r])
      expect(@r.roles).to eq([@my])
    end
    
    it "should add and remove groups correctly" do
      @my.groups << (@x = create :group)
      @my.groups << create(:group)
      expect(@my.groups.size).to eq(2)
      @x.destroy
      @my.reload
      expect(@my.groups.size).to eq(1)
    end
    
        
    it "should include rights HABTM" do
      expect(@my.rights).to eq([])
      @r = create :right
      @my.rights << @r
      expect(@my.rights).to eq([@r])
      expect(@r.roles).to eq([@my])
    end
    
    it "should add and remove rights correctly" do
      @my.rights << (@x = create :right)
      @my.rights << create(:right)
      expect(@my.rights.size).to eq(2)
      @x.destroy
      @my.reload
      expect(@my.rights.size).to eq(1)
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
        expect(ix.length).to eq(3)
        expect(ix[0]).to be_a Role
      end
    
      it "should allow matches on name" do
        expect(Role.collection(name: 'NOWAI').length).to eq(0)
        expect(Role.collection(name: 'Webshop Designer').length).to eq(1)
        expect(Role.collection(name: 'Accountant').length).to eq(1)
      end
      
      it "should allow searches on description" do
        expect(Role.collection(search: 'wa').length).to eq(2)
        expect(Role.collection(search: 'e').length).to eq(3)
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        expect(Role.collection(name: 'System Administrator', aardvark: 12).length).to eq(1)
      end
        
    end
  end

end
