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
#  login_blocked           :boolean          default(FALSE), not null
#  login_blocked_reason    :string(255)
#  indestructible          :boolean          default(FALSE), not null
#
# Indexes
#
#  index_api_users_on_created_by  (created_by)
#  index_api_users_on_updated_at  (updated_at)
#  index_api_users_on_updated_by  (updated_by)
#  index_api_users_on_username    (username) UNIQUE
#

class ApiUser < ActiveRecord::Base

  ocean_resource_model index: [:username, :real_name, :email],
                       search: :email
  

  # Relations
  has_many :authentications, dependent: :destroy

  has_and_belongs_to_many :groups,    # via api_users_groups
    after_add:    [:touch_both],  
    after_remove: [:touch_both]

  has_and_belongs_to_many :roles,     # via api_users_roles
    after_add:    [:touch_both],
    after_remove: [:touch_both]

  # Attributes
  attr_accessible :username, :password, :real_name, :email, :lock_version,
                  :authentication_duration
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
  # Map each right of this ApiUser to a function. Stop if fn returns true for
  # a matching right. This method returns either the matching right, if one 
  # was found, or false if none was found or if fn filtered away all matches.
  #
  # Each right is only considered once. The function is mandatory; each keyword
  # adds further restriction if present and non-false.
  #
  def map_rights(fn, service: nil, resource: nil, hyperlink: nil, verb: nil, 
                     app: nil, context: nil, app_context_acc_fn: nil)
    seen_rights = []
    seen_roles = []
    rsrc = Resource.where(name: resource).first if resource
    cond = rsrc ? {resource_id: rsrc.id} : {}
    # Local function to consider a right. Since this is a Proc (not a lambda), any
    # return in the body will return from the enclosing function (map_rights) rather
    # than from the Proc. This is exactly what we want.
    considerer = Proc.new { |right|
      unless seen_rights.include?(right)
        seen_rights << right
        if (!service   ||                      right.service.name == service) &&
           (!resource  ||                      right.resource.name == resource) &&
           (!hyperlink || right.hyperlink == '*' || right.hyperlink == hyperlink) &&
           (!verb      || right.verb == '*'      || right.verb == verb) 
          # Only the app and context might differ. Process them if function given.
          app_context_acc_fn.call(right) if app_context_acc_fn
          # Now check if this is a full match. If so, call fn.
          if (!app       || right.app == '*'       || right.app == app) &&
             (!context   || right.context == '*'   || right.context == context)
            # If the right authorises the request, return the right, unless a
            # false value returned from fn forces the search to continue.
            return right if fn.call(right)
          end
        end
      end
    }
    roles.each { |role| 
      seen_roles << role
      role.rights.where(cond).each { |right| considerer.call(right) } }
    groups.each { |group| 
      group.rights.where(cond).each { |right| considerer.call(right) } 
      group.roles.each { |role| 
        next if seen_roles.include?(role)
        seen_roles << role
        role.rights.where(cond).each { |right| considerer.call(right) } 
      }
    }
    false
  end

end
