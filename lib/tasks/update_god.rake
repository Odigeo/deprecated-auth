#
# This task sets up the God Role to include all God Rights.
#

namespace :ocean do
  
  desc "Seeds and updates the God Role"
  task :update_god => :environment do

    require 'api_user'

    puts "============================================================"
    puts "Processing the God Role...", ''

    god = ApiUser.find_by_username('god')

    # Attend to the Role
    role_name = "God"
    role_description = "The God Role, containing all superuser Rights."
    role = Role.find_by_name role_name
    if role
      puts "Updating the God Role."
      role.description = role_description
    else
      puts "Creating the God Role."
      role = Role.new name: role_name, description: role_description
    end
    role.created_by = god.id
    role.updated_by = god.id
    role.save!
    puts "God Role saved."

    # Attach all the God Rights to the Role
    role.rights = Right.where(hyperlink: "*", verb: "*", app: "*", context: "*")
    puts "All superuser Rights are now assigned to the God Role."

    # Attach the role to the God user
    god.roles = [role]
    puts "The God Role is now assigned to the God user as its single Role."

    # All done.
    puts "Done."
  end

end
