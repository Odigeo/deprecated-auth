class TheModel < ActiveRecord::Base

  ocean_resource_model invalidate_member:     ['/', '$', '?', lambda { |m| "foo/bar/baz($|?)" }],
                       invalidate_collection: ['$', '?']

  attr_accessible :name, :description, :lock_version

  validates :name, length: { minimum: 3 }

end
