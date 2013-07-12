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
  
  it "should trigger two BANs when created" do
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models?")
  	create :the_model
  end


  it "should trigger five BANs when updated" do
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models?")
  	m = create :the_model
  	m.name = "Zalagadoola"
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{m.id}$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{m.id}?")
   	Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{m.id}/")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models?")
 	  m.save!
  end


  it "should trigger five BANs when touched" do
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models?")
  	m = create :the_model
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{m.id}$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{m.id}?")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{m.id}/")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models?")
 	  m.touch
  end


  it "should trigger five BANs when destroyed" do
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models?")
  	m = create :the_model
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{m.id}$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{m.id}?")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models/#{m.id}/")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models$")
    Api.should_receive(:call_p).once.with("http://127.0.0.1", :ban, "/v1/the_models?")
  	m.destroy
  end

end
