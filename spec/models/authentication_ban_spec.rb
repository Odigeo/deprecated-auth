require 'spec_helper'


describe Authentication do

  before :each do
    stub_const "LOAD_BALANCERS", ["127.0.0.1"]
  end


  it "should have an empty varnish_invalidate_member list" do
    Authentication.varnish_invalidate_member.length.should == 0
  end

  it "should have an empty varnish_invalidate_collection list" do
    Authentication.varnish_invalidate_collection.length.should == 0
  end


  it "should trigger no BANs when created" do
    Api.should_not_receive(:call_p).with("http://127.0.0.1", :ban, Api.escape("/v[0-9]+/authentications/TheToken"))
  	create :authentication, token: "TheToken"
  end


  it "should trigger no BANs when updated" do
    Api.stub(:call_p)
    m = create :authentication
    Api.should_not_receive(:call_p).with("http://127.0.0.1", :ban, Api.escape("/v[0-9]+/authentications/#{m.token}"))
    m.token = "Zalagadoola"
 	  m.save!
  end


  it "should trigger no BANs when touched" do
    Api.stub(:call_p)
    m = create :authentication
    Api.should_not_receive(:call_p).with("http://127.0.0.1", :ban, Api.escape("/v[0-9]+/authentications/#{m.token}"))
 	  m.touch
  end


  it "should trigger one BAN when destroyed" do
    Api.stub(:call_p)
    m = create :authentication
    Api.should_receive(:call_p).with("http://127.0.0.1", :ban, Api.escape("/v[0-9]+/authentications/#{m.token}"))
  	m.destroy
  end

end
