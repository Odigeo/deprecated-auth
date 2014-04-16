class DropSqlAuthentications < ActiveRecord::Migration

  def up
    ActiveRecord::Base.connection.execute("DROP TABLE authentications")
  end


  def down
    create_table "authentications", force: true do |t|
      t.string   "token",       limit: 32, null: false
      t.integer  "max_age",                null: false
      t.datetime "created_at",             null: false
      t.datetime "expires_at",             null: false
      t.integer  "api_user_id"
    end

    add_index "authentications", ["api_user_id"], name: "index_authentications_on_api_user_id"
    add_index "authentications", ["created_at"], name: "index_authentications_on_created_at"
    add_index "authentications", ["token"], name: "index_authentications_on_token", unique: true
  end

end
