# == Schema Information
#
# Table name: roles
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  description        :string(255)      default(""), not null
#  lock_version       :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by         :integer          default(0), not null
#  updated_by         :integer          default(0), not null
#  indestructible     :boolean          default(FALSE), not null
#  documentation_href :string(255)
#
# Indexes
#
#  index_roles_on_created_by  (created_by)
#  index_roles_on_name        (name) UNIQUE
#  index_roles_on_updated_at  (updated_at)
#  index_roles_on_updated_by  (updated_by)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role do
    name         { "role_#{rand(1000000)}" }
    description  "This is a description of the Role."
    lock_version 0
  end
end
