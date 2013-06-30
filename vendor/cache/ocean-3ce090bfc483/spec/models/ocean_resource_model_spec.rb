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
    @c.ocean_resource_model index: [:name]    # Restore class
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
    @c.ocean_resource_model search: :description   # Restore the class
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

end
