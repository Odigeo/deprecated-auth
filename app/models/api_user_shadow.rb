class ApiUserShadow < OceanDynamo::Table

  ocean_resource_model index: [:username], 
                       search: false,
                       invalidate_member: [],
                       invalidate_collection: []

  dynamo_schema(:username, table_name_suffix: Api.basename_suffix, 
                           create: Rails.env != "production",
                           timestamps: nil,
                           locking: false) do
    attribute :password_hash,            :string
    attribute :password_salt,            :string
    attribute :authentication_duration,  :integer
    attribute :login_blocked,            :boolean,  default: false
    attribute :login_blocked_reason,     :string
  end
  
  validates :username, presence: true


  def authenticates?(plaintext_password)
    password_hash == BCrypt::Engine.hash_secret(plaintext_password, password_salt)
  end

end
