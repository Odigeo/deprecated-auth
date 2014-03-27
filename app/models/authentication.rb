# == Schema Information
#
# Table name: authentications
#
#  id          :integer          not null, primary key
#  token       :string(255)      not null
#  max_age     :integer          not null
#  created_at  :datetime         not null
#  expires_at  :datetime         not null
#  api_user_id :integer
#
# Indexes
#
#  index_authentications_on_expires_at  (expires_at)
#  index_authentications_on_token       (token) UNIQUE
#  index_authentications_per_user       (api_user_id,created_at,expires_at)
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
    result = false
    acs = []
    wildcarded = (app == '*' && context == '*')
    # Examine all rights, don't stop at a full match if both app and context are wildcarded
    api_user.map_rights(lambda { |right| result = right; !wildcarded },
          app_context_acc_fn: lambda { |right| acs << {'app' => right.app, 'context' => right.context} unless right.app == '*' && right.context == '*' },
          service: service, resource: resource, 
          hyperlink: hyperlink, verb: verb, 
          app: app, context: context)
    return result if result
    wildcarded && acs != [] && acs
  end

end
