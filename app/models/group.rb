# == Schema Information
#
# Table name: groups
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  description        :string(255)      default(""), not null
#  lock_version       :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by         :integer          default(0), not null
#  updated_by         :integer          default(0), not null
#  indestructible     :boolean          default(FALSE), not null
#  documentation_href :string(255)
#
# Indexes
#
#  index_groups_on_created_by  (created_by)
#  index_groups_on_name        (name) UNIQUE
#  index_groups_on_updated_at  (updated_at)
#  index_groups_on_updated_by  (updated_by)
#

class Group < ActiveRecord::Base

  ocean_resource_model
  

  # Relations
  has_and_belongs_to_many :api_users,         # via api_users_groups
    after_add:    :touch_both, 
    after_remove: :touch_both

  has_and_belongs_to_many :roles,             # via groups_roles
    after_add:    :touch_both, 
    after_remove: :touch_both

  has_and_belongs_to_many :rights,            # via groups_rights
    after_add:    :touch_both, 
    after_remove: :touch_both
    
  # Attributes
  attr_accessible :description, :lock_version, :name, :documentation_href
  
  # Validations
  validates :name, presence: true
  
end
