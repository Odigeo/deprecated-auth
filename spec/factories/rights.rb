# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :right do
    description  "This is a description of the Right."
    lock_version 0
    resource
    hyperlink    { "hyperlink_#{rand(1000000)}" }
    verb         "*"
    app          { "app_#{rand(1000000)}" }
    context      { "context_#{rand(1000000)}" }
  end
end
