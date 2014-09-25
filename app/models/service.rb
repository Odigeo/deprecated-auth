# == Schema Information
#
# Table name: services
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  description        :string(255)      default(""), not null
#  lock_version       :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by         :integer          default(0), not null
#  updated_by         :integer          default(0), not null
#  documentation_href :string(255)
#
# Indexes
#
#  index_services_on_created_by  (created_by)
#  index_services_on_name        (name) UNIQUE
#  index_services_on_updated_at  (updated_at)
#  index_services_on_updated_by  (updated_by)
#

class Service < ActiveRecord::Base

  ocean_resource_model


  # Relations
  has_many :resources, dependent: :destroy

  # Attributes
  attr_accessible :description, :lock_version, :name, :documentation_href
  
  # Validations
  validates :name, presence: true
  validates :name, :format => /\A[a-z][a-z0-9_]*\z/

end
