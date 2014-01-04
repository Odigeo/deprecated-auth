# == Schema Information
#
# Table name: rights
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  description  :string(255)      default(""), not null
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  created_by   :integer          default(0), not null
#  updated_by   :integer          default(0), not null
#  hyperlink    :string(128)      default("*"), not null
#  verb         :string(16)       default("*"), not null
#  app          :string(128)      default("*"), not null
#  context      :string(128)      default("*"), not null
#  resource_id  :integer
#
# Indexes
#
#  app_rights_index            (app,context)
#  index_rights_on_created_by  (created_by)
#  index_rights_on_name        (name) UNIQUE
#  index_rights_on_updated_at  (updated_at)
#  index_rights_on_updated_by  (updated_by)
#  main_rights_index           (resource_id,hyperlink,verb,app,context) UNIQUE
#

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
