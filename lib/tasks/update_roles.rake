#
# This rake task sets up any required Roles. 
#

namespace :ocean do
  
  desc "Updates Roles"
  task :update_roles => :environment do

    require 'role'

    puts "============================================================"
    puts "Processing Roles...", ''

    f = File.join(Rails.root, "config/seeding_data.yml")
    roles = YAML.load(File.read(f))['roles'] || []

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

    puts "Done."
  end


end
