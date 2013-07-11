class UpdateApiUsersForAuthStuff < ActiveRecord::Migration

  def up
    Rake::Task['ocean:update_api_users'].reenable
    Rake::Task['ocean:update_api_users'].invoke
  end

end
