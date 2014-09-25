# == Schema Information
#
# Table name: resources
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  description        :string(255)      default(""), not null
#  lock_version       :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  service_id         :integer
#  created_by         :integer
#  updated_by         :integer
#  documentation_href :string(255)
#
# Indexes
#
#  index_resources_on_name        (name) UNIQUE
#  index_resources_on_service_id  (service_id)
#  index_resources_on_updated_at  (updated_at)
#

class Resource < ActiveRecord::Base

  ocean_resource_model


  # Relations
  belongs_to :service
  has_many :rights, dependent: :destroy

  # Attributes
  attr_accessible :description, :lock_version, :name, :documentation_href
  
  # Validations
  validates :name, presence: true
  validates :name, :format => /\A[a-z][a-z0-9_]*\z/

  validates :service_id, presence: true
  
end
