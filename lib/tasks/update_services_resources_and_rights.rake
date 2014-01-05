#
# This task makes sure the DB has all Services, Resources, and Rights needed for authorisation.
# This script is idempotent.
#
# For this reason, this task should be run as part of deployment, whether
# by TeamCity agents or of environments such as master, staging, and prod.
#
require 'pp'

namespace :ocean do
  
  desc "Updates the basic set of Services, Resources and Rights"
  task :update_services_resources_and_rights => :environment do

    require 'api_user'
    require 'service'
    require 'resource'
    require 'right'
 
    puts "============================================================"
    puts "Updating Services, Resources, and Rights..."
   
    f = File.join(Rails.root, "config/seeding_data.yml")
    basic_set = YAML.load(File.read(f))['structure']

    basic_set.each { |s| update_service(s.deep_dup) }
    puts
    set_creator_and_updater
    puts "Done."
  end


  def update_service(s)
    puts
    service = Service.find_by_name s['name']
    if service
      puts "Updating service #{s['name']}."
      service.send(:update_attributes, s.except('resources'))
    else
      puts "Creating service #{s['name']}."
      service = Service.create! s.except('resources')
    end
    s['resources'].each { |r| update_resources(service, r) }
  end


  def update_resources(service, r)
    resource = service.resources.find_by_name r['name']
    if resource
      puts "| Updating resource #{r['name']}"
      resource.send(:update_attributes, r.except('rights', 'version'))
    else
      puts "| Creating resource #{r['name']}"
      resource = service.resources.create!(r.except('rights', 'version'))
    end
    canonical_names = []
    r['rights'].each { |ri| canonical_names << update_rights(resource, ri) }
    resource.reload
    resource.rights.each do |right|
      unless canonical_names.include?(right.name)
        puts "| | Deleting right [#{right.hyperlink} #{right.verb}] - #{right.description}"
        right.destroy
      end
    end
  end


  def update_rights(resource, r)
    hyperlink = r['hyperlink'].present? && r['hyperlink'] || '*'
    verb = r['verb'].present? && r['verb'] || '*'
    app = r['app'].present? && r['app'] || '*'
    context = r['context'].present? && r['context'] || '*'
    name = "#{resource.service.name}:#{resource.name}:#{hyperlink}:#{verb}:#{app}:#{context}"
    right = resource.rights.find_by_name name
    if right
      lv_before = right.lock_version
      right.send(:update_attributes, r)
      puts "| | Updated right [#{hyperlink} #{verb}] - #{r['description']}" if lv_before != right.lock_version
    else
      puts "| | Creating right [#{hyperlink} #{verb}] - #{r['description']}"
      resource.rights.create!(r)
    end
    name
  end


  def set_creator_and_updater
    god = ApiUser.find_by_username('god')
    return unless god
    god_id = god.id
    Service.all.each do |u|
      (u.created_by = god_id) rescue nil
      (u.updated_by = god_id) rescue nil
      u.save! if u.changed?
    end
    Resource.all.each do |u|
      (u.created_by = god_id) rescue nil
      (u.updated_by = god_id) rescue nil
      u.save! if u.changed?
    end
    Right.all.each do |u|
      (u.created_by = god_id) rescue nil
      (u.updated_by = god_id) rescue nil
      u.save! if u.changed?
    end
  end

end


