# == Schema Information
#
# Table name: the_models
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  description  :string(255)      default(""), not null
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  created_by   :integer          default(0), not null
#  updated_by   :integer          default(0), not null
#

require 'spec_helper'


describe TheModel do

  it "should have a varnish_invalidate_member list of four items" do
    TheModel.varnish_invalidate_member.length.should == 4
  end

  it "should have a varnish_invalidate_collection list of two items" do
    TheModel.varnish_invalidate_collection.length.should == 2
  end


  it "should trigger three BANs when created" do
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models?")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/foo/bar/baz($|?)")
  	create :the_model
  end


  it "should trigger six BANs when updated" do
    Api.stub(:call_p)
  	m = create :the_model
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models?")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models/#{m.id}$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models/#{m.id}?")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models/#{m.id}/")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/foo/bar/baz($|?)")
    m.name = "Zalagadoola"
 	  m.save!
  end


  it "should trigger six BANs when touched" do
    Api.stub(:call_p)
  	m = create :the_model
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models?")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models/#{m.id}$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models/#{m.id}?")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models/#{m.id}/")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/foo/bar/baz($|?)")
 	  m.touch
  end


  it "should trigger six BANs when destroyed" do
    Api.stub(:call_p)
  	m = create :the_model
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models?")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models/#{m.id}$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models/#{m.id}?")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/the_models/#{m.id}/")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v[0-9]+/foo/bar/baz($|?)")
  	m.destroy
  end

end
