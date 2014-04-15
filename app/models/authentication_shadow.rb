class AuthenticationShadow < OceanDynamo::Table

  ocean_resource_model index: [:token], 
                       search: false,
                       invalidate_member: [],
                       invalidate_collection: []

  dynamo_schema(:token, table_name_suffix: Api.basename_suffix, 
                        create: Rails.env != "production",
                        timestamps: nil,
                        locking: false) do
    attribute :max_age,     :integer
    attribute :created_at,  :datetime
    attribute :expires_at,  :datetime
    attribute :api_user_id, :integer
  end


  def api_user
    ApiUser.find(api_user_id)
  end

  def api_user=(au)
    self.api_user_id = au.id
  end


  def seconds_remaining
    sec = (expires_at.utc - Time.now.utc).to_i
    sec = 0 if sec < 0
    sec
  end
  
  def expired?
    seconds_remaining <= 0
  end

  def authentication
    Authentication.where(api_user_id: api_user_id).first
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
