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

      puts
      puts "============================================================"
      puts "Processing ApiUsers..."

      # Process the file
      api_users = YAML.load(File.read(f))['required_api_users']
      puts "The number of ApiUsers to process is #{api_users.length}", ''

      # Attend to each ApiUser
      api_users.each do |username, data|
        user = ApiUser.find_by_username username
        # If the 'delete' flag is set, delete rather than create.
        if data['delete']
          if user
            user.destroy
            puts "Deleted #{data['name']}."
          else
            puts "No need to delete #{data['name']} as it doesn't exist."
          end
          next # Proceed to the next User
        end
        unless user
          # New user
          puts "Creating #{username}."
          user = ApiUser.new data.merge({:username => username}).except('indestructible')
          user.indestructible = data['indestructible']
          user.save!
          next # Proceed to next user
        end
        # The user already existed. Update (if different)
        puts "Updating #{username}."
        user.send(:assign_attributes, data.except('indestructible'))
        user.indestructible = data['indestructible']
        user.save!
      end

      # Set any created_by and updated_by fields which still have the default
      god_id = ApiUser.find_by_username('god').id
      ApiUser.where("created_by = 0 OR updated_by = 0").each do |u|
        ((u.created_by = god_id) rescue nil) if u.created_by == 0
        ((u.updated_by = god_id) rescue nil) if u.created_by == 0
        u.save!
      end

      puts "Done."
    end

  end

end
