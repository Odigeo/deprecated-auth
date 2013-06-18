class SeedRights < ActiveRecord::Migration

  def up
    Rake::Task['soa:update_services_resources_and_rights'].invoke
  end

  def down
  end
  
end
