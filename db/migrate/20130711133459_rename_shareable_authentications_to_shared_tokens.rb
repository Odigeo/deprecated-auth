class RenameShareableAuthenticationsToSharedTokens < ActiveRecord::Migration

  def change
  	rename_column :api_users, :shareable_authentications, :shared_tokens
  end

end
