# == Schema Information
#
# Table name: rights
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  description  :string(255)      default(""), not null
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  created_by   :integer          default(0), not null
#  updated_by   :integer          default(0), not null
#  hyperlink    :string(128)      default("*"), not null
#  verb         :string(16)       default("*"), not null
#  app          :string(128)      default("*"), not null
#  context      :string(128)      default("*"), not null
#  resource_id  :integer
#
# Indexes
#
#  app_rights_index            (app,context)
#  index_rights_on_created_by  (created_by)
#  index_rights_on_name        (name) UNIQUE
#  index_rights_on_updated_at  (updated_at)
#  index_rights_on_updated_by  (updated_by)
#  main_rights_index           (resource_id,hyperlink,verb,app,context) UNIQUE
#

class Right < ActiveRecord::Base

  ocean_resource_model
  

  # Relations
  belongs_to :resource
  delegate :service, :to => :resource
  
  has_and_belongs_to_many :roles,      # via rights_roles
    after_add:    :touch_both, 
    after_remove: :touch_both
  
  has_and_belongs_to_many :groups,     # via groups_rights
    after_add:    :touch_both, 
    after_remove: :touch_both

  # Attributes
  attr_accessible :description, :lock_version,
                  :hyperlink, :verb, :app, :context
  
  # Validations
  validates :name,        presence: true
  validates :resource_id, presence: true
  validates :hyperlink,   format: { with: /\A(\*|[a-z][a-z0-9_]*)\z/,
                                    message: "may only contain the characters a-z, 0-9, and underscores, and must start with a lowercase letter" }
  validates :verb,        inclusion: { in: ['*', 'POST', 'GET', 'GET*', 'PUT', 'DELETE', 'DELETE*'],
                                       message: "must be one of *, POST, GET, GET*, PUT, DELETE, or DELETE*" }
  validates :app,         format: { with: /\A(\*|[A-Za-z0-9_-]+)\z/,
                                    message: "may only contain the characters A-Z, a-z, 0-9, underscore and hyphen" }
  validates :context,     format: { with: /\A(\*|[A-Za-z0-9_-]+)\z/,
                                    message: "may only contain the characters A-Z, a-z, 0-9, underscore and hyphen" }
  
  before_validation do
    self.name = "#{service.name}:#{resource.name}:#{hyperlink}:#{verb}:#{app}:#{context}"
  end

end
