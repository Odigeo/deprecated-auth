# == Schema Information
#
# Table name: resources
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  description        :string(255)      default(""), not null
#  lock_version       :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  service_id         :integer
#  created_by         :integer
#  updated_by         :integer
#  documentation_href :string(255)
#
# Indexes
#
#  index_resources_on_name        (name) UNIQUE
#  index_resources_on_service_id  (service_id)
#  index_resources_on_updated_at  (updated_at)
#

require 'spec_helper'

describe Resource do

  describe "attributes" do
    
    it "should include a name" do
      expect(create(:resource, name: "resource_a").name).to eq("resource_a")
    end

    it "should require the name to be unique" do
      create(:resource, name: "resource_a")
      expect { create(:resource, name: "resource_a") }.to raise_error
    end
    
    it "should require the name to conform to [a-z][a-z0-9_]*" do
      expect(build(:resource, name: "fo2o")).to be_valid
      expect(build(:resource, name: "foo_bar")).to be_valid
      expect(build(:resource, name: "foo_")).to be_valid
      expect(build(:resource, name: "Foo")).not_to be_valid
      expect(build(:resource, name: "2foo")).not_to be_valid
      expect(build(:resource, name: "_foo")).not_to be_valid
      expect(build(:resource, name: "foo-bar")).not_to be_valid
    end

    it "should include a description" do
      expect(create(:resource, description: "A resource description").description).to eq("A resource description")
    end
    
    it "should include a lock_version" do
      expect(create(:resource, lock_version: 24).lock_version).to eq(24)
    end
    
    it "should include a documentation_href" do
      expect(create(:resource, documentation_href: "http://wiki.example.com/foo").documentation_href).to eq("http://wiki.example.com/foo")
    end
    
  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :resource
    end    
      

    it "should belong to a Service" do
      expect(@my.service).to be_a(Service)
    end
    
    it "should contain a number of Rights" do
      expect(@my.rights).to eq([])
    end
    
    it "should destroy all dependent Resources when the Service is destroyed" do
      r1 = create :right, resource: @my
      r2 = create :right, resource: @my
      r3 = create :right
      expect(@my.rights.count).to eq(2)
      @my.destroy
      expect(Right.all).to eq([r3])
    end
    
  end
  

  describe "search" do
  
    describe ".collection" do
    
      before :each do
        create :resource, name: 'foo', description: "The Foo resource"
        create :resource, name: 'bar', description: "The Bar resource"
        create :resource, name: 'baz', description: "The Baz resource"
      end
    
      it "should return an array of Resource instances" do
        ix = Resource.collection
        expect(ix.length).to eq(3)
        expect(ix[0]).to be_a Resource
      end
    
      it "should allow matches on name" do
        expect(Resource.collection(name: 'NOWAI').length).to eq(0)
        expect(Resource.collection(name: 'bar').length).to eq(1)
        expect(Resource.collection(name: 'baz').length).to eq(1)
      end
      
      it "should allow searches on description" do
        expect(Resource.collection(search: 'B').length).to eq(2)
        expect(Resource.collection(search: 'resource').length).to eq(3)
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        expect(Resource.collection(name: 'bar', aardvark: 12).length).to eq(1)
      end
        
    end
  end

end
