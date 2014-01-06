#
# This rake task sets up any required Groups. 
#

namespace :ocean do
  
  desc "Updates Groups"
  task :update_groups => :environment do

    require 'ocean_structure.rb'
    require 'group'

    puts
    puts "============================================================"
    puts "Processing Groups..."

    f = File.join(Rails.root, "config/seeding_data.yml")
    groups = YAML.load(File.read(f))['groups'] || []
    puts "The number of Groups to process is #{groups.length}"

    # Attend to each Role
    groups.each do |data|
      puts ''
      group = Group.find_by_name data['name']

      # If the 'delete' flag is set, delete rather than create.
      if data['delete']
        if group
          group.destroy
          puts "Deleted #{data['name']}."
        else
          puts "No need to delete #{data['name']} as it doesn't exist."
        end
        next # Proceed to the next Group
      end

      # Create or update
      if !group
        # New Group
        puts "Creating #{data['name']}."
        group = Group.create! name: data['name'], description: data['description']
      else
        # The Group already existed. Update (if different)
        puts "Updating #{data['name']}."
        group.update_attributes name: data['name'], description: data['description']
      end

      # Process any rights
      process_rights(group, data['rights'], data['exclusive'])

      # Process any roles
      process_roles(group, data['roles'])

      # Process any api_users
      process_api_users(group, data['api_users'])
    end

    # Set any created_by and updated_by fields which still have the default
    god_id = ApiUser.find_by_username('god').id
    Group.where("created_by = 0 OR updated_by = 0").each do |g|
      ((g.created_by = god_id) rescue nil) if g.created_by == 0
      ((g.updated_by = god_id) rescue nil) if g.created_by == 0
      g.save!
    end

   puts "Done."
  end

end
