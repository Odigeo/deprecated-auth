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
# Indexes
#
#  app_rights_index            (app,context)
#  index_rights_on_created_by  (created_by)
#  index_rights_on_name        (name) UNIQUE
#  index_rights_on_updated_at  (updated_at)
#  index_rights_on_updated_by  (updated_by)
#  main_rights_index           (resource_id,hyperlink,verb,app,context) UNIQUE
#

require 'spec_helper'

describe Right do
  

  describe "attributes" do
    
    it "should include a name" do
      expect(create(:right).name).to be_a(String)
    end

    it "should not allow the name to be set by the user" do
      r = create(:right)
      original_name = r.name
      r.name = "MyNameDammit"
      r.save
      expect(r.name).to eq(original_name)
    end

    it "should set the name to the concatenation of the Right's data attributes" do
      r = create(:right)
      expect(r.name).to eq("#{r.service.name}:#{r.resource.name}:#{r.hyperlink}:#{r.verb}:#{r.app}:#{r.context}")
    end

    it "should require the name to be unique" do
      r = create :resource
      create(:right, resource: r, hyperlink: "foo", verb: "GET", app: "*", context: "*")
      expect { create(:right, resource: r, hyperlink: "foo", verb: "GET", app: "*", context: "*") }.to raise_error
    end

    
    it "should include a description" do
      expect(create(:right, description: "A right description").description).to eq("A right description")
      create(:right).update_attributes(description: "A new description")
    end
    
    it "should include a lock_version" do
      expect(create(:right, lock_version: 24).lock_version).to eq(24)
      create(:right).update_attributes(lock_version: 0)
    end
    
    
    it "should include a hyperlink type" do
      expect(create(:right, hyperlink: "some_hyperlink").hyperlink).to eq("some_hyperlink")
      create(:right).update_attributes(hyperlink: "a_new_hyperlink")
    end
    
    it "should accept a wildcard value for the hyperlink" do
      expect(build(:right, hyperlink: "*")).to be_valid
    end

    it "should require the hyperlink to conform to (\*|[a-z][a-z0-9_]*)" do
      expect(build(:right, hyperlink: "fo2o")).to be_valid
      expect(build(:right, hyperlink: "foo_bar")).to be_valid
      expect(build(:right, hyperlink: "foo_")).to be_valid
      expect(build(:right, hyperlink: "Foo")).not_to be_valid
      expect(build(:right, hyperlink: "2foo")).not_to be_valid
      expect(build(:right, hyperlink: "_foo")).not_to be_valid
      expect(build(:right, hyperlink: "foo-bar")).not_to be_valid
    end
    
    
    it "should include an HTTP verb" do
      expect(create(:right, verb: "DELETE").verb).to eq("DELETE")
      create(:right).update_attributes(verb: "A new verb")
    end
    
    it "should accept a wildcard value for the verb" do
      expect(build(:right, verb: "*")).to be_valid
    end

    it "should limit the wildcard value to one of GET, POST, PUT, DELETE, GET*, and DELETE*" do
      ['GET', 'POST', 'PUT', 'DELETE', 'GET*', 'DELETE*'].each do |v|
        expect(build(:right, verb: v)).to be_valid
      end
    end
    
    it "should reject verbs not part of the canonical set" do
      expect(build(:right, verb: 'PURGE')).not_to be_valid
      expect(build(:right, verb: 'BLAHONGA')).not_to be_valid
    end
    

    it "should include an app" do
      expect(create(:right, app: "some_app").app).to eq("some_app")
      create(:right).update_attributes(app: "A new app")
    end
    
    it "should accept a wildcard value for the app" do
      expect(build(:right, app: "*")).to be_valid
    end
    
    it "should restrict the value of app to uppercase, lowercase, digits, underscores, and hyphens" do
      expect(build(:right, app: "only_lowercase_UPPERCASE_underscores-and-digits-0123456789")).to be_valid
      expect(build(:right, app: "no spaces")).not_to be_valid
    end
    
    
    it "should include a context" do
      expect(create(:right, context: "some_context").context).to eq("some_context")
      create(:right).update_attributes(context: "A new context")
    end
    
    it "should accept a wildcard value for the context" do
      expect(build(:right, context: "*")).to be_valid
    end
    
    it "should restrict the value of context to uppercase, lowercase, digits, underscores, and hyphens" do
      expect(build(:right, context: "only_lowercase_UPPERCASE_underscores-and-digits-0123456789")).to be_valid
      expect(build(:right, context: "no spaces")).not_to be_valid
    end

  end
  
  
  describe "relations" do
    
    before :each do
      @my = create :right
    end
    
    
    it "should belong to a Resource" do
      expect(@my.resource).to be_a(Resource)
    end
    
    it "should belong to a Service" do
      expect(@my.service).to be_a(Service)
    end
    
    

    it "should include groups HABTM" do
      expect(@my.groups).to eq([])
      @u = create :group
      @my.groups << @u
      expect(@my.groups).to eq([@u])
      expect(@u.rights).to eq([@my])
    end
    
    it "should add and remove groups correctly" do
      @my.groups << (@x = create :group)
      @my.groups << create(:group)
      expect(@my.groups.size).to eq(2)
      @x.destroy
      @my.reload
      expect(@my.groups.size).to eq(1)
    end
    
        
    it "should include roles HABTM" do
      expect(@my.roles).to eq([])
      @r = create :role
      @my.roles << @r
      expect(@my.roles).to eq([@r])
      expect(@r.rights).to eq([@my])
    end
    
    it "should add and remove roles correctly" do
      @my.roles << (@x = create :role)
      @my.roles << create(:role)
      expect(@my.roles.size).to eq(2)
      @x.destroy
      @my.reload
      expect(@my.roles.size).to eq(1)
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
        expect(ix.length).to eq(3)
        expect(ix[0]).to be_a Right
      end
    
      it "should allow matches on name" do
        expect(Right.collection(name: 'NOWAI').length).to eq(0)
        expect(Right.collection(name: @r1.name).length).to eq(1)
        expect(Right.collection(name: @r2.name).length).to eq(1)
      end
      
      it "should allow searches on description" do
        expect(Right.collection(search: 'res').length).to eq(2)
        expect(Right.collection(search: 'e').length).to eq(3)
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        expect(Right.collection(name: @r3.name, aardvark: 12).length).to eq(1)
      end
        
    end
  end

end
