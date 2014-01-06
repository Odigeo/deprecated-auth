#
# This rake task sets up any required Roles. 
#

namespace :ocean do
  
  desc "Updates Roles"
  task :update_roles => :environment do

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
        role = Role.create! name: data['name'], description: data['description']
      else
        # The Role already existed. Update (if different)
        puts "Updating #{data['name']}."
        role.update_attributes name: data['name'], description: data['description']
      end

      # Process any rights
      if data['exclusive']
        puts "| Cleared all rights of #{data['name']}"
        role.rights = [] 
      end
      (data['rights'] || []).each do |x|
        if x.is_a?(Hash) && x['regexp']
          Right.all.each do |r|
            if r.name =~ Regexp.new(x['regexp']) && !role.rights.include?(r)
              puts "| Added the regexp matched #{r.name} right to #{data['name']}"
              role.rights << r 
            end
          end
        else
          r = Right.find_by_name x
          role.rights << r if r && !role.rights.include?(r)
          puts "| Added #{r.name} right to #{data['name']}"
        end
      end

      # Process any api_users
      (data['api_users'] || []).each do |username|
        u = ApiUser.find_by_username username
        puts "| Couldn't add non-existent ApiUser #{username}" and next unless u
        if role.api_users.include?(u)
          puts "| The #{username} ApiUser already has the #{data['name']} role"
        else
          role.api_users << u
          puts "| Added the #{data['name']} role to the #{username} ApiUser"
        end
      end
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
