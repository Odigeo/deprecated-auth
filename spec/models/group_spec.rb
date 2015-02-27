# == Schema Information
#
# Table name: groups
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
#  index_groups_on_created_by  (created_by)
#  index_groups_on_name        (name) UNIQUE
#  index_groups_on_updated_at  (updated_at)
#  index_groups_on_updated_by  (updated_by)
#

require 'spec_helper'

describe Group do
  
  describe "attributes" do
    
    it "should include a name" do
      expect(create(:group, name: "A Group").name).to eq("A Group")
    end
    
    it "should include a description" do
      expect(create(:group, name: "glurg", description: "A group description").description).to eq("A group description")
    end
    
    it "should include a documentation_href" do
      expect(create(:group, documentation_href: "http://wiki.example.com/foo").documentation_href).to eq("http://wiki.example.com/foo")
    end
    it "should include a lock_version" do
      expect(create(:group, lock_version: 24).lock_version).to eq(24)
    end
    
  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :group
    end
        
    
    it "should include api_users HABTM" do
      expect(@my.api_users).to eq([])
      @u = create :api_user
      @my.api_users << @u
      expect(@my.api_users).to eq([@u])
      expect(@u.groups).to eq([@my])
    end
    
    it "should add and remove api_users correctly" do
      @my.api_users << (@x = create :api_user)
      @my.api_users << create(:api_user)
      expect(@my.api_users.size).to eq(2)
      @x.destroy
      @my.reload
      expect(@my.api_users.size).to eq(1)
    end
        
        
    it "should include roles HABTM" do
      expect(@my.roles).to eq([])
      @r = create :role
      @my.roles << @r
      expect(@my.roles).to eq([@r])
      expect(@r.groups).to eq([@my])
    end
    
    it "should add and remove roles correctly" do
      @my.roles << (@x = create :role)
      @my.roles << create(:role)
      expect(@my.roles.size).to eq(2)
      @x.destroy
      @my.reload
      expect(@my.roles.size).to eq(1)
    end

        
    it "should include rights HABTM" do
      expect(@my.rights).to eq([])
      @r = create :right
      @my.rights << @r
      expect(@my.rights).to eq([@r])
      expect(@r.groups).to eq([@my])
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
        create :group, name: 'Admins', description: "For system administrators"
        create :group, name: 'Webshop', description: "For everyone involved in ecommerce"
        create :group, name: 'Management', description: "Suits"
      end

    
      it "should return an array of Group instances" do
        ix = Group.collection
        expect(ix.length).to eq(3)
        expect(ix[0]).to be_a Group
      end
    
      it "should allow matches on name" do
        expect(Group.collection(name: 'NOWAI').length).to eq(0)
        expect(Group.collection(name: 'Webshop').length).to eq(1)
        expect(Group.collection(name: 'Management').length).to eq(1)
      end
      
      it "should allow searches on description" do
        expect(Group.collection(search: 'For').length).to eq(2)
        expect(Group.collection(search: 'i').length).to eq(3)
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        expect(Group.collection(name: 'Admins', aardvark: 12).length).to eq(1)
      end
        
    end
  end

end
