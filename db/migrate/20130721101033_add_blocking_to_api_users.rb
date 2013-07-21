class AddBlockingToApiUsers < ActiveRecord::Migration

  def change
    add_column :api_users, :login_blocked,        :boolean, default: false, null: false
    add_column :api_users, :login_blocked_reason, :string
  end
  
end
