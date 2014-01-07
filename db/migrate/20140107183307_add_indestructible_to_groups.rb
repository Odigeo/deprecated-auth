class AddIndestructibleToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :indestructible, :boolean, default: false, null: false
  end
end
