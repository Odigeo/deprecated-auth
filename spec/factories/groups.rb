# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    name         { "group_#{rand(1000000)}" }
    description  "This is a description of the Group."
    lock_version 0
  end
end
