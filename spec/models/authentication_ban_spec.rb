require 'spec_helper'


describe Authentication do

  before :each do
    stub_const "LOAD_BALANCERS", ["127.0.0.1"]
  end


  it "should have an empty varnish_invalidate_member list" do
    expect(Authentication.varnish_invalidate_member.length).to eq(0)
  end

  it "should have an empty varnish_invalidate_collection list" do
    expect(Authentication.varnish_invalidate_collection.length).to eq(0)
  end


  it "should trigger no BANs when created" do
    expect(Api).not_to receive(:ban).with("/v[0-9]+/authentications/TheToken")
  	create :authentication, token: "TheToken"
  end


  it "should trigger no BANs when updated" do
    allow(Api).to receive(:call_p)
    m = create :authentication
    expect(Api).not_to receive(:ban).with("/v[0-9]+/authentications/#{m.token}")
    m.token = "Zalagadoola"
 	  m.save!
  end


  it "should trigger no BANs when touched" do
    allow(Api).to receive(:call_p)
    m = create :authentication
    expect(Api).not_to receive(:ban).with("/v[0-9]+/authentications/#{m.token}")
 	  m.touch
  end


  it "should trigger one BAN when destroyed" do
    allow(Api).to receive(:call_p)
    m = create :authentication
    expect(Api).to receive(:ban).with("/v[0-9]+/authentications/#{m.token}")
  	m.destroy
  end

end
