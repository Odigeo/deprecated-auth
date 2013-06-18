# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role do
    name         { "role_#{rand(1000000)}" }
    description  "This is a description of the Role."
    lock_version 0
  end
end
