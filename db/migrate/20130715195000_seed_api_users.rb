class SeedApiUsers < ActiveRecord::Migration

  def up
    Rake::Task['ocean:update_api_users'].invoke
  end

  def down
    ApiUser.destroy_all
  end

end