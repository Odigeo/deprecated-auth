class AddAuthenticationDurationToApiUser < ActiveRecord::Migration

  def change
  	add_column :api_users, :authentication_duration, :integer, null: false, default: 30.minutes
  end

end
