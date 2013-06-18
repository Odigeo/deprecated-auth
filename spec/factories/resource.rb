# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :resource do
    name         { "resource_#{rand(1000000)}" }
    description  "This is a description of the Resource."
    lock_version 0
    service
  end
end
