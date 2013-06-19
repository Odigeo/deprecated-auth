class SeedRights < ActiveRecord::Migration

  def up
    Rake::Task['ocean:update_services_resources_and_rights'].invoke
  end

  def down
  end
  
end
