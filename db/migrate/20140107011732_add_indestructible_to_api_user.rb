class AddIndestructibleToApiUser < ActiveRecord::Migration
  def change
    add_column :api_users, :indestructible, :boolean, default: false, null: false
  end
end
