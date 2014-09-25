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
      create(:service, name: "service_a").name.should == "service_a"
    end

    it "should require the name to be unique" do
      create(:service, name: "service_a")
      expect { create(:service, name: "service_a") }.to raise_error
    end

    it "should require the name to conform to [a-z][a-z0-9_]*" do
      build(:service, name: "x").should be_valid
      build(:service, name: "fo2o").should be_valid
      build(:service, name: "foo_bar").should be_valid
      build(:service, name: "foo_").should be_valid
      build(:service, name: "Foo").should_not be_valid
      build(:service, name: "2foo").should_not be_valid
      build(:service, name: "_foo").should_not be_valid
      build(:service, name: "foo-bar").should_not be_valid
    end

    
    it "should include a description" do
      create(:service, name: "blah", description: "A service description").description.should == "A service description"
    end
    
    it "should include a documentation_href" do
      create(:service, documentation_href: "http://wiki.example.com/foo").documentation_href.should == "http://wiki.example.com/foo"
    end

    it "should include a lock_version" do
      create(:service, lock_version: 24).lock_version.should == 24
    end
    
  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :service
    end
    
    
    it "should contain a number of Resources" do
      @my.resources.should == []
    end
    
    it "should destroy all dependent Resources when the Service is destroyed" do
      Resource.destroy_all
      r1 = create :resource, service: @my
      r2 = create :resource, service: @my
      r3 = create :resource
      @my.resources.count.should == 2
      @my.destroy
      Resource.all.should == [r3]
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
        ix.length.should == 3
        ix[0].should be_a Service
      end
    
      it "should allow matches on name" do
        Service.collection(name: 'NOWAI').length.should == 0
        Service.collection(name: 'bar').length.should == 1
        Service.collection(name: 'baz').length.should == 1
      end
      
      it "should allow searches on description" do
        Service.collection(search: 'B').length.should == 2
        Service.collection(search: 'service').length.should == 3
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        Service.collection(name: 'bar', aardvark: 12).length.should == 1
      end
        
    end
  end

end
