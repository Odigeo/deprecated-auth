class TheModel < ActiveRecord::Base

  ocean_resource_model

  attr_accessible :name, :description, :lock_version

  validates :name, length: { minimum: 3 }

end
