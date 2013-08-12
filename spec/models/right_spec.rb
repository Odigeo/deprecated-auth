# == Schema Information
#
# Table name: rights
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  description  :string(255)      default(""), not null
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  created_by   :integer          default(0), not null
#  updated_by   :integer          default(0), not null
#  hyperlink    :string(128)      default("*"), not null
#  verb         :string(16)       default("*"), not null
#  app          :string(128)      default("*"), not null
#  context      :string(128)      default("*"), not null
#  resource_id  :integer
#

require 'spec_helper'

describe Right do
  

  describe "attributes" do
    
    it "should include a name" do
      create(:right).name.should be_a(String)
    end

    it "should not allow the name to be set by the user" do
      r = create(:right)
      original_name = r.name
      r.name = "MyNameDammit"
      r.save
      r.name.should == original_name
    end

    it "should set the name to the concatenation of the Right's data attributes" do
      r = create(:right)
      r.name.should == "#{r.service.name}:#{r.resource.name}:#{r.hyperlink}:#{r.verb}:#{r.app}:#{r.context}"
    end

    it "should require the name to be unique" do
      r = create :resource
      create(:right, resource: r, hyperlink: "foo", verb: "GET", app: "*", context: "*")
      expect { create(:right, resource: r, hyperlink: "foo", verb: "GET", app: "*", context: "*") }.to raise_error
    end

    
    it "should include a description" do
      create(:right, description: "A right description").description.should == "A right description"
      create(:right).update_attributes(description: "A new description")
    end
    
    it "should include a lock_version" do
      create(:right, lock_version: 24).lock_version.should == 24
      create(:right).update_attributes(lock_version: 0)
    end
    
    
    it "should include a hyperlink type" do
      create(:right, hyperlink: "some_hyperlink").hyperlink.should == "some_hyperlink"
      create(:right).update_attributes(hyperlink: "a_new_hyperlink")
    end
    
    it "should accept a wildcard value for the hyperlink" do
      build(:right, hyperlink: "*").should be_valid
    end

    it "should require the hyperlink to conform to (\*|[a-z][a-z0-9_]*)" do
      build(:right, hyperlink: "fo2o").should be_valid
      build(:right, hyperlink: "foo_bar").should be_valid
      build(:right, hyperlink: "foo_").should be_valid
      build(:right, hyperlink: "Foo").should_not be_valid
      build(:right, hyperlink: "2foo").should_not be_valid
      build(:right, hyperlink: "_foo").should_not be_valid
      build(:right, hyperlink: "foo-bar").should_not be_valid
    end
    
    
    it "should include an HTTP verb" do
      create(:right, verb: "DELETE").verb.should == "DELETE"
      create(:right).update_attributes(verb: "A new verb")
    end
    
    it "should accept a wildcard value for the verb" do
      build(:right, verb: "*").should be_valid
    end
    
    it "should limit the wildcard value to one of GET, POST, PUT, DELETE, and GET*" do
      ['GET', 'POST', 'PUT', 'DELETE', 'GET*'].each do |v|
        build(:right, verb: v).should be_valid
      end
    end
    
    it "should reject verbs not part of the canonical set" do
      build(:right, verb: 'PURGE').should_not be_valid
      build(:right, verb: 'BLAHONGA').should_not be_valid
    end
    

    it "should include an app" do
      create(:right, app: "some_app").app.should == "some_app"
      create(:right).update_attributes(app: "A new app")
    end
    
    it "should accept a wildcard value for the app" do
      build(:right, app: "*").should be_valid
    end
    
    it "should restrict the value of app to uppercase, lowercase, digits, underscores, and hyphens" do
      build(:right, app: "only_lowercase_UPPERCASE_underscores-and-digits-0123456789").should be_valid
      build(:right, app: "no spaces").should_not be_valid
    end
    
    
    it "should include a context" do
      create(:right, context: "some_context").context.should == "some_context"
      create(:right).update_attributes(context: "A new context")
    end
    
    it "should accept a wildcard value for the context" do
      build(:right, context: "*").should be_valid
    end
    
    it "should restrict the value of context to uppercase, lowercase, digits, underscores, and hyphens" do
      build(:right, context: "only_lowercase_UPPERCASE_underscores-and-digits-0123456789").should be_valid
      build(:right, context: "no spaces").should_not be_valid
    end

  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :right
    end
    
    
    it "should belong to a Resource" do
      @my.resource.should be_a(Resource)
    end
    
    it "should belong to a Service" do
      @my.service.should be_a(Service)
    end
    
    

    it "should include groups HABTM" do
      @my.groups.should == []
      @u = create :group
      @my.groups << @u
      @my.groups.should == [@u]
      @u.rights.should == [@my]
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
      @r.rights.should == [@my]
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
  

  describe "search" do

    describe ".collection" do
    
      before :each do
        @r1 = create :right, description: "Confers every right in the system. Handle with extreme care."
        @r2 = create :right, description: "Makes resource representations contain admin data"
        @r3 = create :right, description: "Contains authorisation data for REST API Text resources"
      end
    
      it "should return an array of Group instances" do
        ix = Right.collection
        ix.length.should == 3
        ix[0].should be_a Right
      end
    
      it "should allow matches on name" do
        Right.collection(name: 'NOWAI').length.should == 0
        Right.collection(name: @r1.name).length.should == 1
        Right.collection(name: @r2.name).length.should == 1
      end
      
      it "should allow searches on description" do
        Right.collection(search: 'res').length.should == 2
        Right.collection(search: 'e').length.should == 3
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        Right.collection(name: @r3.name, aardvark: 12).length.should == 1
      end
        
    end
  end

end
