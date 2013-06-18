# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :service do
    name         { "service_#{rand(1000000)}" }
    description  "This is a description of the Service."
    lock_version 0
  end
end
