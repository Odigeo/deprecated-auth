# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130627130901) do

  create_table "api_users", :force => true do |t|
    t.string   "username",                      :null => false
    t.string   "password_hash",                 :null => false
    t.string   "password_salt",                 :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "real_name",     :default => ""
    t.integer  "lock_version",  :default => 0,  :null => false
    t.string   "email",         :default => "", :null => false
    t.integer  "created_by",    :default => 0,  :null => false
    t.integer  "updated_by",    :default => 0,  :null => false
  end

  add_index "api_users", ["created_by"], :name => "index_api_users_on_created_by"
  add_index "api_users", ["updated_at"], :name => "index_api_users_on_updated_at"
  add_index "api_users", ["updated_by"], :name => "index_api_users_on_updated_by"
  add_index "api_users", ["username"], :name => "index_api_users_on_username", :unique => true

  create_table "api_users_groups", :id => false, :force => true do |t|
    t.integer "api_user_id", :null => false
    t.integer "group_id",    :null => false
  end

  add_index "api_users_groups", ["api_user_id", "group_id"], :name => "index_api_users_groups_on_api_user_id_and_group_id", :unique => true
  add_index "api_users_groups", ["group_id", "api_user_id"], :name => "index_api_users_groups_on_group_id_and_api_user_id", :unique => true

  create_table "api_users_roles", :id => false, :force => true do |t|
    t.integer "api_user_id", :null => false
    t.integer "role_id",     :null => false
  end

  add_index "api_users_roles", ["api_user_id", "role_id"], :name => "index_api_users_roles_on_api_user_id_and_role_id", :unique => true
  add_index "api_users_roles", ["role_id", "api_user_id"], :name => "index_api_users_roles_on_role_id_and_api_user_id", :unique => true

  create_table "authentications", :force => true do |t|
    t.string   "token",       :limit => 32, :null => false
    t.integer  "max_age",                   :null => false
    t.datetime "created_at",                :null => false
    t.datetime "expires_at",                :null => false
    t.integer  "api_user_id"
  end

  add_index "authentications", ["api_user_id"], :name => "index_authentications_on_api_user_id"
  add_index "authentications", ["created_at"], :name => "index_authentications_on_created_at"
  add_index "authentications", ["token"], :name => "index_authentications_on_token", :unique => true

  create_table "groups", :force => true do |t|
    t.string   "name",                         :null => false
    t.string   "description",  :default => "", :null => false
    t.integer  "lock_version", :default => 0,  :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "created_by",   :default => 0,  :null => false
    t.integer  "updated_by",   :default => 0,  :null => false
  end

  add_index "groups", ["created_by"], :name => "index_groups_on_created_by"
  add_index "groups", ["name"], :name => "index_groups_on_name", :unique => true
  add_index "groups", ["updated_at"], :name => "index_groups_on_updated_at"
  add_index "groups", ["updated_by"], :name => "index_groups_on_updated_by"

  create_table "groups_rights", :id => false, :force => true do |t|
    t.integer "group_id", :null => false
    t.integer "right_id", :null => false
  end

  add_index "groups_rights", ["group_id", "right_id"], :name => "index_groups_rights_on_group_id_and_right_id", :unique => true
  add_index "groups_rights", ["right_id", "group_id"], :name => "index_groups_rights_on_right_id_and_group_id", :unique => true

  create_table "groups_roles", :id => false, :force => true do |t|
    t.integer "group_id", :null => false
    t.integer "role_id",  :null => false
  end

  add_index "groups_roles", ["group_id", "role_id"], :name => "index_groups_roles_on_group_id_and_role_id", :unique => true
  add_index "groups_roles", ["role_id", "group_id"], :name => "index_groups_roles_on_role_id_and_group_id", :unique => true

  create_table "resources", :force => true do |t|
    t.string   "name",                         :null => false
    t.string   "description",  :default => "", :null => false
    t.integer  "lock_version", :default => 0,  :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "service_id"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "resources", ["name"], :name => "index_resources_on_name", :unique => true
  add_index "resources", ["service_id"], :name => "index_resources_on_service_id"
  add_index "resources", ["updated_at"], :name => "index_resources_on_updated_at"

  create_table "rights", :force => true do |t|
    t.string   "name",                                         :null => false
    t.string   "description",                 :default => "",  :null => false
    t.integer  "lock_version",                :default => 0,   :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "created_by",                  :default => 0,   :null => false
    t.integer  "updated_by",                  :default => 0,   :null => false
    t.string   "hyperlink",    :limit => 128, :default => "*", :null => false
    t.string   "verb",         :limit => 16,  :default => "*", :null => false
    t.string   "app",          :limit => 128, :default => "*", :null => false
    t.string   "context",      :limit => 128, :default => "*", :null => false
    t.integer  "resource_id"
  end

  add_index "rights", ["app", "context"], :name => "app_rights_index"
  add_index "rights", ["created_by"], :name => "index_rights_on_created_by"
  add_index "rights", ["name"], :name => "index_rights_on_name", :unique => true
  add_index "rights", ["resource_id", "hyperlink", "verb", "app", "context"], :name => "main_rights_index", :unique => true
  add_index "rights", ["updated_at"], :name => "index_rights_on_updated_at"
  add_index "rights", ["updated_by"], :name => "index_rights_on_updated_by"

  create_table "rights_roles", :id => false, :force => true do |t|
    t.integer "right_id", :null => false
    t.integer "role_id",  :null => false
  end

  add_index "rights_roles", ["right_id", "role_id"], :name => "index_rights_roles_on_right_id_and_role_id", :unique => true
  add_index "rights_roles", ["role_id", "right_id"], :name => "index_rights_roles_on_role_id_and_right_id", :unique => true

  create_table "roles", :force => true do |t|
    t.string   "name",                         :null => false
    t.string   "description",  :default => "", :null => false
    t.integer  "lock_version", :default => 0,  :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "created_by",   :default => 0,  :null => false
    t.integer  "updated_by",   :default => 0,  :null => false
  end

  add_index "roles", ["created_by"], :name => "index_roles_on_created_by"
  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true
  add_index "roles", ["updated_at"], :name => "index_roles_on_updated_at"
  add_index "roles", ["updated_by"], :name => "index_roles_on_updated_by"

  create_table "services", :force => true do |t|
    t.string   "name",                         :null => false
    t.string   "description",  :default => "", :null => false
    t.integer  "lock_version", :default => 0,  :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "created_by",   :default => 0,  :null => false
    t.integer  "updated_by",   :default => 0,  :null => false
  end

  add_index "services", ["created_by"], :name => "index_services_on_created_by"
  add_index "services", ["name"], :name => "index_services_on_name", :unique => true
  add_index "services", ["updated_at"], :name => "index_services_on_updated_at"
  add_index "services", ["updated_by"], :name => "index_services_on_updated_by"

end
