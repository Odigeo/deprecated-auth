class OptimiseAuthenticationsIndex < ActiveRecord::Migration

  def change
    add_index "authentications", ["api_user_id", "expires_at"]
    remove_index "authentications", name: "index_authentications_per_user"
  end

end
