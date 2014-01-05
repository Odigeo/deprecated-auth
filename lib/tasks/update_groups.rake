#
# This rake task sets up any required Groups. 
#

namespace :ocean do
  
  desc "Updates Groups"
  task :update_groups => :environment do

    require 'group'

    puts
    puts "============================================================"
    puts "Processing Groups..."

    f = File.join(Rails.root, "config/seeding_data.yml")
    groups = YAML.load(File.read(f))['groups'] || []
    puts "The number of Groups to process is #{groups.length}", ''

    # Attend to each Role
    groups.each do |data|
      group = Group.find_by_name data['name']
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
