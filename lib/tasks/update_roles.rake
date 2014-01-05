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
    puts "The number of Roles to process is #{roles.length}", ''

    # Attend to each Role
    roles.each do |data|
      role = Role.find_by_name data['name']
      unless role
        # New Role
        puts "Creating #{data['name']}."
        Role.create! data
        next # Proceed to next Role
      end
      # The Role already existed. Update (if different)
      puts "Updating #{data['name']}."
      role.send(:update_attributes, data)
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
