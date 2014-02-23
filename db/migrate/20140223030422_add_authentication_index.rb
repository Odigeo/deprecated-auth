class AddAuthenticationIndex < ActiveRecord::Migration

  def change
    add_index "authentications", ["api_user_id", "created_at", "expires_at"], name: "index_authentications_per_user"
    add_index "authentications", ["expires_at"]
    remove_index "authentications", ["api_user_id"]
    remove_index "authentications", ["created_at"]
  end

end
