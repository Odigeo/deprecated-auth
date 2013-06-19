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
    
    email = 'peter@peterbengtson.com'
    email2 = 'lasse.edlund@odigeo.com'
    [['god',                     password: '0mn1p0t3ns', email: email,  real_name: 'God'],
     ['auth',                    password: 'subr0s4',    email: email,  real_name: 'Auth service'],
     ['cms',                     password: '4l3x4ndr14', email: email,  real_name: 'CMS service'],
     ['log',                     password: 't1mb3r',     email: email,  real_name: 'Log service'],
     ['media',                   password: 'mult1',      email: email,  real_name: 'Media service'],
     ['admin_client',            password: 'f1stpump',   email: email2, real_name: 'Admin client'],
     ['admin_client_testuser',   password: 'test123',    email: email2, real_name: 'Admin client test user'],
     ['webshop_client',          password: 'blah0nga',   email: email2, real_name: 'Webshop client'],
     ['webshop_client_testuser', password: 'test123',    email: email2, real_name: 'Webshop client test user']
    ].each do |username, data|
      user = ApiUser.find_by_username username
      if user
        puts "Updating #{username}."
        user.send(:update_attributes, data)
      else
        puts "Creating #{username}."
        ApiUser.create! data.merge({:username => username})
      end
    end
    god_id = ApiUser.find_by_username('god').id
    ApiUser.all.each do |u|
      (u.created_by = god_id) rescue nil
      (u.updated_by = god_id) rescue nil
      u.save!
    end
    puts "Done."
  end

end
