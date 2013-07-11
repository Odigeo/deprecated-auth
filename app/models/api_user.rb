# == Schema Information
#
# Table name: api_users
#
#  id                      :integer          not null, primary key
#  username                :string(255)      not null
#  password_hash           :string(255)      not null
#  password_salt           :string(255)      not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  real_name               :string(255)      default("")
#  lock_version            :integer          default(0), not null
#  email                   :string(255)      default(""), not null
#  created_by              :integer          default(0), not null
#  updated_by              :integer          default(0), not null
#  authentication_duration :integer          default(1800), not null
#  shared_tokens           :boolean          default(FALSE), not null
#

class ApiUser < ActiveRecord::Base

  ocean_resource_model index: [:username, :real_name, :email],
                       search: :email
  

  # Relations
  has_many :authentications, dependent: :destroy

  has_and_belongs_to_many :groups, after_add: :touch_both, after_remove: :touch_both   # via api_users_groups
  has_and_belongs_to_many :roles,  after_add: :touch_both, after_remove: :touch_both   # via api_users_roles

  # Attributes
  attr_accessible :username, :password, :real_name, :email, :lock_version,
                  :authentication_duration, :shared_tokens
  attr_reader :password

  # Validations
  validates :username, presence: true
  validates :username, format: /\A[A-Za-z][A-Za-z0-9_-]+\z/, 
                       unless: lambda { |u| u.username.blank? }
  validates :password, presence: true, on: :create, 
                                       if: lambda { |u| u.password_hash.blank? }
  validates :password_hash, presence: true
  validates :password_salt, presence: true
  validates :lock_version, presence: true
  validates :email, presence: true
  validates :authentication_duration, presence: true, 
                                      numericality: { only_integer: true, greater_than: 0 }


  def self.find_by_credentials(un, pw)
    # Don't bother going to the DB if credentials are missing
    return nil if un == "" && pw == ""
    # Consult the DB
    user = find_by_username(un)
    user && !!user.authenticates?(pw) && user
  end


  def password=(plaintext_password)
    return if plaintext_password.blank?
  	self.password_salt = BCrypt::Engine.generate_salt
  	self.password_hash = BCrypt::Engine.hash_secret(plaintext_password, password_salt)
  end
  
  def authenticates?(plaintext_password)
    password_hash == BCrypt::Engine.hash_secret(plaintext_password, password_salt)
  end


  #
  # The sum of all rights in each group, plus the rights of each role
  #
  def all_rights
    sum = []
    groups.each { |group| sum = (sum + group.all_rights) }
    roles.each { |role| sum = (sum + role.rights) }
    sum.uniq
  end


  #
  # Returns the token to use when creating an Authentication for this ApiUser.
  # If shared_tokens is true, an existing token will be used, if one exists.
  # Otherwise a new token will be created and returned.
  #
  def authentication_token
    return Authentication.new_token unless shared_tokens
    auth = authentications.order(:created_at).last
    return Authentication.new_token unless auth
    auth.token
  end

end
