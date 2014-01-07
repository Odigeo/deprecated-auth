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

FactoryGirl.define do
  
  factory :api_user do
    username	{ "user_#{rand(100000000)}" }
 	password 	{ "password_#{rand(10000000)}" }
 	email       { "somebody_#{rand(10000000)}@example.com" }
  end
  
end
