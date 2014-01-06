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
      if data['exclusive']
        puts "  Cleared all rights of #{data['name']}"
        group.rights = [] 
      end
      (data['rights'] || []).each do |x|
        if x.is_a?(Hash) && x['regexp']
          Right.all.each do |r|
            if r.name =~ Regexp.new(x['regexp']) && !group.rights.include?(r)
              puts "  Added the regexp matched #{r.name} right to #{data['name']}"
              group.rights << r 
            end
          end
        else
          r = Right.find_by_name x
          group.rights << r if r && !group.rights.include?(r)
          puts "  Added #{r.name} right to #{data['name']}"
        end
      end

      # Process any api_users
      (data['api_users'] || []).each do |username|
        u = ApiUser.find_by_username username
        puts "| Couldn't add non-existent ApiUser #{username}" and next unless u
        if group.api_users.include?(u)
          puts "| The #{username} ApiUser already belongs to the #{data['name']} group"
        else
          group.api_users << u
          puts "| The #{username} ApiUser now belongs to the #{data['name']} group"
        end
      end

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
