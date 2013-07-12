require 'spec_helper'
 
describe TheModel do

  before :each do
    @i = TheModel.new
    @c = @i.class
  end


  it "ocean_resource_model should be available as a class method" do
  	@c.ocean_resource_model
  end
  


  it "should accept an :index keyword arg" do
  	@c.ocean_resource_model index: [:name]
  end
    
  it ":index should default to [:name]" do
  	@c.ocean_resource_model
  	@c.index_only.should == [:name]
  end

  it ":index should be reachable through a class method" do
  	@c.ocean_resource_model index: [:foo, :bar]
  	@c.index_only.should == [:foo, :bar]
    @c.ocean_resource_model    # Restore class
  end

  it "should have an index class method" do
  	@c.index
  end



  it "should accept an :search keyword arg" do
  	@c.ocean_resource_model search: :description
  end
    
  it ":search should default to :description" do
  	@c.ocean_resource_model
  	@c.index_search_property.should == :description
  end

  it ":search should be reachable through a class method" do
  	@c.ocean_resource_model search: :zalagadoola
  	@c.index_search_property.should == :zalagadoola
    @c.ocean_resource_model   # Restore the class
  end



  it "should have a latest_api_version class method" do
  	@c.latest_api_version.should == "v1"
  end



  it "should have an instance method to touch two instances" do
  	other = TheModel.new
  	@i.should_receive(:touch).once
  	other.should_receive(:touch).once
  	@i.touch_both(other)
  end


  it "should accept an :invalidate_collection keyword arg" do
    @c.ocean_resource_model invalidate_collection: ['$', '?']
  end

  it ":invalidate_collection should default to ['$', '?']" do
    @c.ocean_resource_model
    @c.varnish_invalidate_collection.should == ['$', '?']
  end

  it ":invalidate_collection should be reachable through a class method" do
    @c.ocean_resource_model invalidate_collection: ['a', 'b', 'c']
    @c.varnish_invalidate_collection.should == ['a', 'b', 'c']
    @c.ocean_resource_model # Restore the class
  end

  it "should have a class method to invalidate all collections in Varnish" do
    Api.stub(:call_p)
    @c.invalidate
  end

  it "the invalidation class method should use the suffixes defined by :invalidate_collection" do
    # The basic collection
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models?")
    # Do it!
    @c.invalidate
  end


  it "should accept an :invalidate_member keyword arg" do
    @c.ocean_resource_model invalidate_member: ['/', '$', '?']
  end

  it ":invalidate_member should default to ['/', '$', '?']" do
    @c.ocean_resource_model
    @c.varnish_invalidate_member.should == ['/', '$', '?']
  end

  it ":invalidate_member should be reachable through a class method" do
    @c.ocean_resource_model invalidate_member: ['x', 'y', 'z']
    @c.varnish_invalidate_member.should == ['x', 'y', 'z']
    @c.ocean_resource_model  # Restore the class
  end

  it "should have an instance method to invalidate itself in Varnish" do
    Api.stub(:call_p)
    @i.invalidate
  end

  it "the invalidation instance method should use the suffixes defined by :invalidate_member AND :invalidate_collection" do
    # The basic collection
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models?")
    # The member itself
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{@i.id}$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{@i.id}?")
    # The member's subordinate relations/collections
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{@i.id}/")
    # Do it!
    @i.invalidate
  end


end
