FactoryGirl.define do
  
  factory :authentication do
    api_user
    username   { api_user.username }
    token      { SecureRandom.urlsafe_base64(20) }
    max_age    30.minutes
    created_at { Time.now.utc }
    expires_at { Time.now.utc + 30.minutes }
  end
  
  factory :authentication_shadow do
    api_user
    username   { api_user.username }
    token      { SecureRandom.urlsafe_base64(20) }
    max_age    30.minutes
    created_at { Time.now.utc }
    expires_at { Time.now.utc + 30.minutes }
  end
  

end
