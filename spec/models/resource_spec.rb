# == Schema Information
#
# Table name: resources
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  description  :string(255)      default(""), not null
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  service_id   :integer
#  created_by   :integer
#  updated_by   :integer
#

require 'spec_helper'

describe Resource do

  describe "attributes" do
    
    it "should include a name" do
      create(:resource, name: "resource_a").name.should == "resource_a"
    end

    it "should require the name to be unique" do
      create(:resource, name: "resource_a")
      expect { create(:resource, name: "resource_a") }.to raise_error
    end
    
    it "should require the name to conform to [a-z][a-z0-9_]*" do
      build(:resource, name: "fo2o").should be_valid
      build(:resource, name: "foo_bar").should be_valid
      build(:resource, name: "foo_").should be_valid
      build(:resource, name: "Foo").should_not be_valid
      build(:resource, name: "2foo").should_not be_valid
      build(:resource, name: "_foo").should_not be_valid
      build(:resource, name: "foo-bar").should_not be_valid
    end

    it "should include a description" do
      create(:resource, description: "A resource description").description.should == "A resource description"
    end
    
    it "should include a lock_version" do
      create(:resource, lock_version: 24).lock_version.should == 24
    end
    
  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :resource
    end    
      

    it "should belong to a Service" do
      @my.service.should be_a(Service)
    end
    
    it "should contain a number of Rights" do
      @my.rights.should == []
    end
    
    it "should destroy all dependent Resources when the Service is destroyed" do
      r1 = create :right, resource: @my
      r2 = create :right, resource: @my
      r3 = create :right
      @my.rights.count.should == 2
      @my.destroy
      Right.all.should == [r3]
    end
    
  end
  

  describe "search" do
    describe ".index_only" do
      it "should return an array of permitted search query args" do
        Resource.index_only.should be_an Array
      end
    end
  
    describe ".index" do
    
      before :each do
        create :resource, name: 'foo', description: "The Foo resource"
        create :resource, name: 'bar', description: "The Bar resource"
        create :resource, name: 'baz', description: "The Baz resource"
      end
    
      it "should return an array of Resource instances" do
        ix = Resource.index
        ix.length.should == 3
        ix[0].should be_a Resource
      end
    
      it "should allow matches on name" do
        Resource.collection(name: 'NOWAI').length.should == 0
        Resource.collection(name: 'bar').length.should == 1
        Resource.collection(name: 'baz').length.should == 1
      end
      
      it "should allow searches on description" do
        Resource.collection(search: 'B').length.should == 2
        Resource.collection(search: 'resource').length.should == 3
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        Resource.collection(name: 'bar', aardvark: 12).length.should == 1
      end
        
    end
  end

end
