# == Schema Information
#
# Table name: services
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  description        :string(255)      default(""), not null
#  lock_version       :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by         :integer          default(0), not null
#  updated_by         :integer          default(0), not null
#  documentation_href :string(255)
#
# Indexes
#
#  index_services_on_created_by  (created_by)
#  index_services_on_name        (name) UNIQUE
#  index_services_on_updated_at  (updated_at)
#  index_services_on_updated_by  (updated_by)
#

require 'spec_helper'

describe Service do
  
  describe "attributes" do
        
    it "should include a name" do
      expect(create(:service, name: "service_a").name).to eq("service_a")
    end

    it "should require the name to be unique" do
      create(:service, name: "service_a")
      expect { create(:service, name: "service_a") }.to raise_error
    end

    it "should require the name to conform to [a-z][a-z0-9_]*" do
      expect(build(:service, name: "x")).to be_valid
      expect(build(:service, name: "fo2o")).to be_valid
      expect(build(:service, name: "foo_bar")).to be_valid
      expect(build(:service, name: "foo_")).to be_valid
      expect(build(:service, name: "Foo")).not_to be_valid
      expect(build(:service, name: "2foo")).not_to be_valid
      expect(build(:service, name: "_foo")).not_to be_valid
      expect(build(:service, name: "foo-bar")).not_to be_valid
    end

    
    it "should include a description" do
      expect(create(:service, name: "blah", description: "A service description").description).to eq("A service description")
    end
    
    it "should include a documentation_href" do
      expect(create(:service, documentation_href: "http://wiki.example.com/foo").documentation_href).to eq("http://wiki.example.com/foo")
    end

    it "should include a lock_version" do
      expect(create(:service, lock_version: 24).lock_version).to eq(24)
    end
    
  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :service
    end
    
    
    it "should contain a number of Resources" do
      expect(@my.resources).to eq([])
    end
    
    it "should destroy all dependent Resources when the Service is destroyed" do
      Resource.destroy_all
      r1 = create :resource, service: @my
      r2 = create :resource, service: @my
      r3 = create :resource
      expect(@my.resources.count).to eq(2)
      @my.destroy
      expect(Resource.all).to eq([r3])
    end
            
  end
  

  describe "search" do
  
    describe ".collection" do
    
      before :each do
        create :service, name: 'foo', description: "The Foo service"
        create :service, name: 'bar', description: "The Bar service"
        create :service, name: 'baz', description: "The Baz service"
      end
    
      it "should return an array of Service instances" do
        ix = Service.collection
        expect(ix.length).to eq(3)
        expect(ix[0]).to be_a Service
      end
    
      it "should allow matches on name" do
        expect(Service.collection(name: 'NOWAI').length).to eq(0)
        expect(Service.collection(name: 'bar').length).to eq(1)
        expect(Service.collection(name: 'baz').length).to eq(1)
      end
      
      it "should allow searches on description" do
        expect(Service.collection(search: 'B').length).to eq(2)
        expect(Service.collection(search: 'service').length).to eq(3)
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        expect(Service.collection(name: 'bar', aardvark: 12).length).to eq(1)
      end
        
    end
  end

end
