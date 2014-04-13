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
#  index_authentications_on_api_user_id_and_expires_at  (api_user_id,expires_at)
#  index_authentications_on_expires_at                  (expires_at)
#  index_authentications_on_token                       (token) UNIQUE
#

FactoryGirl.define do
  
  factory :authentication do
    api_user
    token      { SecureRandom.urlsafe_base64(20) }
    max_age    30.minutes
    created_at { Time.now.utc }
    expires_at { Time.now.utc + 30.minutes }
  end
  
end
