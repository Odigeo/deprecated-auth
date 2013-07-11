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

FactoryGirl.define do
  
  factory :api_user do
    username	{ "user_#{rand(100000000)}" }
 	password 	{ "password_#{rand(10000000)}" }
 	email       { "somebody_#{rand(10000000)}@example.com" }
  end
  
end
