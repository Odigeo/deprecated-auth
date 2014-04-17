class Authentication < OceanDynamo::Table

  ocean_resource_model index: [:token], 
                       search: false,
                       invalidate_member: [], 
                       invalidate_collection: []


  dynamo_schema(:username, :expires_at,
                table_name_suffix: Api.basename_suffix, 
                create: Rails.env != "production",
                timestamps: nil,
                locking: false) do
    attribute :token,       :string
    attribute :max_age,     :integer
    attribute :created_at,  :datetime
    attribute :expires_at,  :datetime
    attribute :api_user_id, :integer
  end

  
  # Relations
  
  #belongs_to :api_user
  def api_user=(u)
    self.api_user_id = u.id
  end

  def api_user
    ApiUser.find api_user_id
  end
    

  # Callbacks
  after_save do |auth|
    AuthenticationShadow.create! token: auth.token,
                                 max_age: auth.max_age,
                                 created_at: auth.created_at,
                                 expires_at: auth.expires_at,
                                 api_user_id: auth.api_user_id,
                                 username: auth.username
  end

  after_destroy do |auth|
    # The following line invalidates all authorisations done using this Authentication
    Api.ban "/v[0-9]+/authentications/#{auth.token}"
    # Until we have secondary indices and thus can avoid the AuthenticationShadow
    # altogether, the 1:1 relationship between original and shadow can't be guaranteed.
    # Thus the destroy is conditional as the shadow may already have been deleted.
    shadow = auth.authentication_shadow
    shadow.destroy if shadow
    true
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


  def authentication_shadow
    AuthenticationShadow.find(token)
  end

end
