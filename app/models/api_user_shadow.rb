class ApiUserShadow < OceanDynamo::Table

  ocean_resource_model index: [:username], 
                       search: false,
                       invalidate_member: [],
                       invalidate_collection: []

  dynamo_schema(:username, table_name_suffix: Api.basename_suffix, 
                           create: Rails.env != "production",
                           timestamps: nil,
                           locking: false) do
    attribute :api_user_id,              :integer
    attribute :password_hash,            :string
    attribute :password_salt,            :string
    attribute :authentication_duration,  :integer
    attribute :login_blocked,            :boolean,  default: false
    attribute :login_blocked_reason,     :string
  end
  
  validates :username, presence: true
  validates :api_user_id, presence: true


  def self.find_by_credentials(un, pw)
    # Don't bother going to the DB if credentials are missing
    return nil if un == "" && pw == ""
    # Consult the DB
    user = find_by_key(un) || false
    user && !!user.authenticates?(pw) && user
  end

  def authenticates?(plaintext_password)
    password_hash == BCrypt::Engine.hash_secret(plaintext_password, password_salt)
  end


  # def latest_authentication
  #   Authentication.where(api_user_id: api_user_id).order(:expires_at).last
  # end


  def latest_authentication
    Authentication.dynamo_items.query(hash_value: username, range_gte: 0,
                                      scan_index_forward: false, batch_size: 1,
                                      select: :all) do |item_data|
      return Authentication.new._setup_from_dynamo(item_data)
    end
    nil
  end

end
