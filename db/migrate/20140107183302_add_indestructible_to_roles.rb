class AddIndestructibleToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :indestructible, :boolean, default: false, null: false
  end
end
