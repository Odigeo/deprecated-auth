class SeedGod < ActiveRecord::Migration

  def up
    Rake::Task['ocean:update_god'].reenable
    Rake::Task['ocean:update_god'].invoke
  end

  def down
  end

end
