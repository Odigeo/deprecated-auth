#
# This task makes sure the DB has the api_users needed for authentication.
# This script will never modify any existing data except password, email and
# real_name. This means that this script can be run at any time exactly in
# order to update those values.
#
# For this reason, this task should be run as part of deployment, whether
# by TeamCity agents or of environments such as master, staging, and prod.
#

namespace :ocean do
  
  desc "Updates password, email and real name for all system API users"
  task :update_api_users => :environment do

    require 'api_user'

    f = File.join(Rails.root, "config/seeding_data.yml")
    unless File.exists?(f)
      puts
      puts "-----------------------------------------------------------------------"
      puts "The tailored seeding data file is missing. Please copy"
      puts "config/seeding_data.yml.example to config/seeding_data.yml and tailor"
      puts "its contents to suit your dev setup."
      puts
      puts "NB: seeding_data.yml is excluded from git version control as it will" 
      puts "    contain data private to your Ocean system."
      puts "-----------------------------------------------------------------------"
      puts
      abort
    end
    api_users = YAML.load(File.read(f))['required_api_users']

    api_users.each do |username, data|
      user = ApiUser.find_by_username username
      if user
        puts "Updating #{username}."
        user.send(:update_attributes, data)
      else
        puts "Creating #{username}."
        ApiUser.create! data.merge({:username => username})
      end
    end
    god_id = ApiUser.find_by_username('god').id
    ApiUser.all.each do |u|
      (u.created_by = god_id) rescue nil
      (u.updated_by = god_id) rescue nil
      u.save!
    end
    puts "Done."
  end

end
