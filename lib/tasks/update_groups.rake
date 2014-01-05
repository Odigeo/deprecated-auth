#
# This rake task sets up any required Groups. 
#

namespace :ocean do
  
  desc "Updates Groups"
  task :update_groups => :environment do

    require 'group'

    puts "============================================================"
    puts "Updating Groups..."

    f = File.join(Rails.root, "config/seeding_data.yml")
    groups = YAML.load(File.read(f))['groups'] || []

    # Attend to each Role
    groups.each do |data|
      groups = Group.find_by_name data['name']
      unless group
        # New Group
        puts "Creating #{data['name']}."
        Group.create! data
        next # Proceed to next Group
      end
      # The Group already existed. Update (if different)
      puts "Updating #{data['name']}."
      group.send(:update_attributes, data)
    end

    puts "Done."
  end


end
