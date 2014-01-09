# == Schema Information
#
# Table name: authentications
#
#  id          :integer          not null, primary key
#  token       :string(32)       not null
#  max_age     :integer          not null
#  created_at  :datetime         not null
#  expires_at  :datetime         not null
#  api_user_id :integer
#
# Indexes
#
#  index_authentications_on_api_user_id  (api_user_id)
#  index_authentications_on_created_at   (created_at)
#  index_authentications_on_token        (token) UNIQUE
#

class Authentication < ActiveRecord::Base

  ocean_resource_model index: [:token], 
                       search: false,
                       invalidate_member: [], 
                       invalidate_collection: []


  scope :active,      lambda { where("expires_at > ?", Time.current.utc) }
  scope :old_expired, lambda { where("expires_at <= ?", 1.hour.ago.utc) }
  
  # Relations
  belongs_to :api_user
  
  # Attributes
  attr_accessible :api_user, :token, :max_age, :created_at, :expires_at
  
  # Validations
  validates :api_user, :associated => true  
  validates :api_user_id, :presence => true
  
  # Callbacks
  after_destroy do |auth|
    v = Authentication.latest_api_version
    # The following line invalidates all authorisations done using this Authentication
    Api.ban "/v[0-9]+/authentications/#{auth.token}"
    # Authentication collections are never cached, thus no need to invalidate them.
  end


  # Class methods 

  def self.new_token
    SecureRandom.urlsafe_base64(32)
  end

  
  # Instance methods

  def seconds_remaining
    sec = (expires_at.utc - Time.now.utc).to_i
    sec = 0 if sec < 0
    sec
  end
  
  def expired?
    seconds_remaining <= 0
  end
  
  def active?
    !expired?
  end
  
  def authorized?(service, resource, hyperlink, verb, app, context)
    rights = api_user.all_rights.select { |r| r.service.name == service && r.resource.name == resource }
    rights.each do |r|
      return true if (r.hyperlink == '*' || hyperlink == r.hyperlink) &&
                     (r.verb == '*'      || verb == r.verb) &&
                     (r.app == '*'       || app == r.app) &&
                     (r.context == '*'   || context == r.context)
    end
    false
  end

end
