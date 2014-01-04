# == Schema Information
#
# Table name: groups
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  description  :string(255)      default(""), not null
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  created_by   :integer          default(0), not null
#  updated_by   :integer          default(0), not null
#
# Indexes
#
#  index_groups_on_created_by  (created_by)
#  index_groups_on_name        (name) UNIQUE
#  index_groups_on_updated_at  (updated_at)
#  index_groups_on_updated_by  (updated_by)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    name         { "group_#{rand(1000000)}" }
    description  "This is a description of the Group."
    lock_version 0
  end
end
