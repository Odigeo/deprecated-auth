#
# This rake task sets up any required Roles. 
#

namespace :ocean do
  
  desc "Updates Roles"
  task :update_roles => :environment do

    require 'ocean_structure.rb'
    require 'role'

    puts
    puts "============================================================"
    puts "Processing Roles..."

    f = File.join(Rails.root, "config/seeding_data.yml")
    roles = YAML.load(File.read(f))['roles'] || []
    puts "The number of Roles to process is #{roles.length}"

    # Attend to each Role
    roles.each do |data|
      puts ''
      role = Role.find_by_name data['name']

      # If the 'delete' flag is set, delete rather than create.
      if data['delete']
        if role
          role.destroy
          puts "Deleted #{data['name']}."
        else
          puts "No need to delete #{data['name']} as it doesn't exist."
        end
        next # Proceed to the next Role
      end

      # Create or update
      if !role
        # New Role
        puts "Creating #{data['name']}."
        role = Role.new name: data['name'], description: data['description']
      else
        # The Role already existed. Update (if different)
        puts "Updating #{data['name']}."
        role.assign_attributes name: data['name'], description: data['description']
      end
      role.indestructible = !!data['indestructible']
      role.documentation_href = data['documentation_href']
      role.save!

      # Process any rights
      process_rights(role, data['rights'], data['exclusive'])

      # Process any api_users
      process_api_users(role, data['api_users'])
    end

    # Set any created_by and updated_by fields which still have the default
    god_id = ApiUser.find_by_username('god').id
    Role.where("created_by = 0 OR updated_by = 0").each do |r|
      ((r.created_by = god_id) rescue nil) if r.created_by == 0
      ((r.updated_by = god_id) rescue nil) if r.created_by == 0
      r.save!
    end

    puts "Done."
  end

end
