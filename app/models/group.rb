# == Schema Information
#
# Table name: groups
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

class Group < ActiveRecord::Base

  ocean_resource_model
  

  # Relations
  has_and_belongs_to_many :api_users, after_add: :touch_both, after_remove: :touch_both    # via api_users_groups
  has_and_belongs_to_many :roles, after_add: :touch_both, after_remove: :touch_both        # via groups_roles
  has_and_belongs_to_many :rights, after_add: :touch_both, after_remove: :touch_both       # via groups_rights
    
  # Attributes
  attr_accessible :description, :lock_version, :name
  
  # Validations
  validates :name, presence: true
  


  def all_rights
    # This is the sum of all rights in each role, plus the locally attached rights
    sum = []
    roles.each { |role| sum = (sum + role.rights) }
    (sum + rights).uniq
  end

end
