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

    # The is the example file
    ef = File.join(Rails.root, "config/seeding_data.yml.example")

    # Only load config data if there is an example file
    if File.exists?(ef)

      # This is the tailored file, not under source control.
      f = File.join(Rails.root, "config/seeding_data.yml")

      # If the tailored file doesn't exist, and we're running in test mode
      # (which is the case under TeamCity), use the example file as-is.
      unless File.exists?(f)
        f = ENV['OCEAN_API_HOST'] ? ef : false
      end

      # If no file to process, abort with an error message
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

      # Process the file
      api_users = YAML.load(File.read(f))['required_api_users']

      api_users.each do |username, data|
        user = ApiUser.find_by_username username
        unless user
          puts "Creating #{username}."
          ApiUser.create! data.merge({:username => username})
          next
        end
        puts "Updating #{username}."
        user.send(:update_attributes, data)
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

end
