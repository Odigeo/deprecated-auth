class RemoveSharedToken < ActiveRecord::Migration

  def change
    remove_column "api_users", :shared_tokens, :boolean, default: false, null: false
  end

end
