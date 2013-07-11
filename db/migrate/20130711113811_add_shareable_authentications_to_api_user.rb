class AddShareableAuthenticationsToApiUser < ActiveRecord::Migration

  def change
  	add_column :api_users, :shareable_authentications, :boolean, null: false, default: false
  end

end
