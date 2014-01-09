class UnlimitedTokenLength < ActiveRecord::Migration

  def up
    change_column :authentications, :token, :string, null: false, limit: nil
  end

  def down
    change_column :authentications, :token, :string, null: false, limit: 32
  end

end
