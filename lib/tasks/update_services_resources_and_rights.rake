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
    
    basic_set = [
      { name:        "auth",
        description: "Authentication and authorisation",
        resources: [
            { name:        "services",
              description: "The Service resource describes a service available in the SOA and the Resources it handles.",
              rights: [
                  { description: "Service resource God" },
                  { description: "Get a Service",                hyperlink: "self", verb: "GET" },
                  { description: "Modify a Service",             hyperlink: "self", verb: "PUT"},
                  { description: "Delete a Service",             hyperlink: "self", verb: "DELETE"},
                  { description: "Create a Service",             hyperlink: "self", verb: "POST"},
                  { description: "Get a collection of Services", hyperlink: "self", verb: "GET*"},
                  { description: "Get a collection of the Service's Resources", hyperlink: "resources", verb: "GET"},
                  { description: "Create a new Resource for the Service",       hyperlink: "resources", verb: "POST"}
                ]},
            { name:        "resources",
              description: "The Resource resource describes a Resource belonging to a Service, as well as the Rights it implements.",
              rights: [
                  { description: "Resource resource God" },
                  { description: "Get a Resource",                hyperlink: "self", verb: "GET" },
                  { description: "Modify a Resource",             hyperlink: "self", verb: "PUT"},
                  { description: "Delete a Resource",             hyperlink: "self", verb: "DELETE"},
                  { description: "Get a collection of Resources", hyperlink: "self", verb: "GET*"},
                  { description: "Get a collection of the Resource's Rights",      hyperlink: "rights", verb: "GET"},
                  { description: "Create a new Right for the Resource",            hyperlink: "rights", verb: "POST"}
                ]},
            { name:        "rights",
              description: "The Right resource describes an access right used for authorisation of a REST operation. Each Right belongs to a Resource.",
              rights: [
                  { description: "Right resource God" },
                  { description: "Get a Right",                hyperlink: "self", verb: "GET" },
                  { description: "Modify a Right",             hyperlink: "self", verb: "PUT"},
                  { description: "Delete a Right",             hyperlink: "self", verb: "DELETE"},
                  { description: "Get a collection of Rights", hyperlink: "self", verb: "GET*"},
                  { description: "Get a collection of the Right's Groups",       hyperlink: "groups", verb: "GET"},
                  { description: "Get a collection of the Right's Roles",        hyperlink: "roles", verb: "GET"},
                  { description: "Connect the Right to another entity",          hyperlink: "connect", verb: "PUT"},
                  { description: "Disconnect the Right from another entity",     hyperlink: "connect", verb: "DELETE"}
                ]},
            { name:        "roles",
              description: "A Role resource is an arbitrary, named combination of Rights.",
              rights: [
                  { description: "Role resource God" },
                  { description: "Get a Role",                hyperlink: "self", verb: "GET" },
                  { description: "Modify a Role",             hyperlink: "self", verb: "PUT"},
                  { description: "Delete a Role",             hyperlink: "self", verb: "DELETE"},
                  { description: "Create a Role",             hyperlink: "self", verb: "POST"},
                  { description: "Get a collection of Roles", hyperlink: "self", verb: "GET*"},
                  { description: "Get a collection of the Roles's ApiUsers", hyperlink: "api_users", verb: "GET"},
                  { description: "Get a collection of the Roles's Groups",   hyperlink: "groups", verb: "GET"},
                  { description: "Get a collection of the Roles's Rights",   hyperlink: "rights", verb: "GET"},
                  { description: "Connect the Role to another entity",       hyperlink: "connect", verb: "PUT"},
                  { description: "Disconnect the Role from another entity",  hyperlink: "connect", verb: "DELETE"}
                ]},
            { name:        "groups",
              description: "A Group resource is an arbitrary, named combination of ApiUsers, Roles, and Rights",
              rights: [
                  { description: "Group resource God" },
                  { description: "Get a Group",                hyperlink: "self", verb: "GET" },
                  { description: "Modify a Group",             hyperlink: "self", verb: "PUT"},
                  { description: "Delete a Group",             hyperlink: "self", verb: "DELETE"},
                  { description: "Create a Group",             hyperlink: "self", verb: "POST"},
                  { description: "Get a collection of Groups", hyperlink: "self", verb: "GET*"},
                  { description: "Get a collection of the Group's ApiUsers",  hyperlink: "api_users", verb: "GET"},
                  { description: "Get a collection of the Group's Roles",     hyperlink: "roles", verb: "GET"},
                  { description: "Get a collection of the Group's Rights",    hyperlink: "rights", verb: "GET"},
                  { description: "Connect the Group to another entity",       hyperlink: "connect", verb: "PUT"},
                  { description: "Disconnect the Group from another entity",  hyperlink: "connect", verb: "DELETE"}
                ]},
            { name:        "api_users",
              description: "An ApiUser is the entity for which an Authentication is made. ApiUsers can be real people, but also abstract entities such as Services or clients.",
              rights: [
                  { description: "ApiUser resource God" },
                  { description: "Get an ApiUser",               hyperlink: "self", verb: "GET" },
                  { description: "Modify an ApiUser",            hyperlink: "self", verb: "PUT"},
                  { description: "Delete an ApiUser",            hyperlink: "self", verb: "DELETE"},
                  { description: "Create an ApiUser",            hyperlink: "self", verb: "POST"},
                  { description: "Get a collection of ApiUsers", hyperlink: "self", verb: "GET*"},
                  { description: "Get a collection of the ApiUser's Authentications",  hyperlink: "authentications", verb: "GET"},
                  { description: "Get a collection of the ApiUser's Roles",            hyperlink: "roles", verb: "GET"},
                  { description: "Get a collection of the ApiUser's Groups",           hyperlink: "groups", verb: "GET"},
                  { description: "Connect the ApiUser to another entity",              hyperlink: "connect", verb: "PUT"},
                  { description: "Disconnect the ApiUser from another entity",         hyperlink: "connect", verb: "DELETE"}
                ]},
            { name:        "authentications",
              description: "An Authentication resource represents an ApiUser whose identity has been verified through its username and its hashed password.",
              rights: [
                  { description: "Authentication resource God" },
                  { description: "Get an Authentication",               hyperlink: "self", verb: "GET" },
                  { description: "Delete an Authentication",            hyperlink: "self", verb: "DELETE"},
                  { description: "Create an Authentication",            hyperlink: "self", verb: "POST"}
                ]}
          ]},
      { name:        "cms",
        description: "Content management system",
        resources: [
            { name:        "texts",
              description: "A Text resource is a named and scoped UI string and its translations into various languages.",
              rights: [
                  { description: "Text resource God" },
                  { description: "Get a Text",                hyperlink: "self", verb: "GET" },
                  { description: "Modify a Text",             hyperlink: "self", verb: "PUT"},
                  { description: "Delete a Text",             hyperlink: "self", verb: "DELETE"},
                  { description: "Create a Text",             hyperlink: "self", verb: "POST"},
                  { description: "Get a collection of Texts", hyperlink: "self", verb: "GET*"}
                ]},
            { name:        "dictionaries",
              description: "A Dictionary is a pseudo-resource used to fetch many Texts at one and the same time, for a specific language.",
              rights: [
                  { description: "Dictionary God" },
                  { description: "Get a Dictionary",          hyperlink: "self", verb: "GET" },
                ]}
          ]},
      { name:        "log",
        description: "Centralised logging",
        resources: [
            { name: "log_excerpts",
              description: "A LogExcerpt is a collection of log entries.",
              rights: [
                  { description: "Log God" },
                  { description: "Get log entries",    hyperlink: "self", verb: "GET" },
                  { description: "Delete log entries", hyperlink: "self", verb: "DELETE" }
                ]
            }
          ]},
      { name:        "media",
        description: "Dynamic management of static assets",
        resources: [
            { name:        "media",
              description: "A Medium resource is a static asset such as an image, a sound file, a video, plain text, HTML or any type of binary data.",
              rights: [
                  { description: "Medium resource God" },
                  { description: "Get a Medium",              hyperlink: "self", verb: "GET" },
                  { description: "Modify a Medium",           hyperlink: "self", verb: "PUT"},
                  { description: "Delete a Medium",           hyperlink: "self", verb: "DELETE"},
                  { description: "Create a Medium",           hyperlink: "self", verb: "POST"},
                  { description: "Get a collection of Media", hyperlink: "self", verb: "GET*"}
                ]},
            { name:        "medium_buckets",
              description: "A MediumBucket is an administrative resource closely tied to the Riak storage backend.",
              rights: [
                  { description: "MediumBucket resource God" },
                  { description: "Get a MediumBucket",                hyperlink: "self", verb: "GET" },
                  { description: "Delete a MediumBucket",             hyperlink: "self", verb: "DELETE"},
                  { description: "Get a collection of MediumBuckets", hyperlink: "self", verb: "GET*"},
                  { description: "Delete all MediumBuckets",          hyperlink: "destroy_all", verb: "DELETE"}
                ]}
          ]},
      { name:        "jobs",
        description: "Asynchronous job service",
        resources: [
            { name: "async_jobs",
              description: "An AsyncJob resource represents a pollable asynchronous job.",
              rights: [
                  { description: "AsyncJob resource God" },
                  { description: "Get an AsyncJob",                hyperlink: "self", verb: "GET" },
                  { description: "Delete an AsyncJob",             hyperlink: "self", verb: "DELETE"},
                  { description: "Create an AsyncJob",             hyperlink: "self", verb: "POST"}
                ]
            }
          ]},
      { name:        "sandbox",
        description: "Paedagogical service",
        resources: [
            { name: "notes",
              description: "A Note resource has a title and a body and is designed for teaching purposes.",
              rights: [
                  { description: "Note resource God" },
                  { description: "Get a Note",                hyperlink: "self", verb: "GET" },
                  { description: "Delete a Note",             hyperlink: "self", verb: "DELETE"},
                  { description: "Create a Note",             hyperlink: "self", verb: "POST"},
                  { description: "Get a collection of Notes", hyperlink: "self", verb: "GET*"},
                  { description: "Get the Comments for this Note",     hyperlink: "comments", verb: "GET"},
                  { description: "Create a new Comment for this Note", hyperlink: "comments", verb: "POST"}
                ]
            },
            { name: "comments",
              description: "Comment resources can be attached to Notes.",
              rights: [
                  { description: "Comment resource God" },
                  { description: "Get a Comment",                hyperlink: "self", verb: "GET" },
                  { description: "Delete a Comment",             hyperlink: "self", verb: "DELETE"},
                  { description: "Get a collection of Comments", hyperlink: "self", verb: "GET*"}
                ]
            }
          ]}
      ]

    basic_set.each { |s| update_service(s) }
    puts
    set_creator_and_updater
    puts "Done."
  end


  def update_service(s)
    puts
    service = Service.find_by_name s[:name]
    if service
      puts "Updating service #{s[:name]}."
      service.send(:update_attributes, s.except(:resources))
    else
      puts "Creating service #{s[:name]}."
      service = Service.create! s.except(:resources)
    end
    s[:resources].each { |r| update_resources(service, r) }
  end


  def update_resources(service, r)
    resource = service.resources.find_by_name r[:name]
    if resource
      puts "| Updating resource #{r[:name]}"
      resource.send(:update_attributes, r.except(:rights))
    else
      puts "| Creating resource #{r[:name]}"
      resource = service.resources.create!(r.except(:rights))
    end
    canonical_names = []
    r[:rights].each { |ri| canonical_names << update_rights(resource, ri) }
    resource.reload
    resource.rights.each do |right|
      unless canonical_names.include?(right.name)
        puts "| | Deleting right [#{right.hyperlink} #{right.verb}] - #{right.description}"
        right.destroy
      end
    end
  end


  def update_rights(resource, r)
    hyperlink = r[:hyperlink].present? && r[:hyperlink] || '*'
    verb = r[:verb].present? && r[:verb] || '*'
    app = r[:app].present? && r[:app] || '*'
    context = r[:context].present? && r[:context] || '*'
    name = "#{resource.service.name}:#{resource.name}:#{hyperlink}:#{verb}:#{app}:#{context}"
    right = resource.rights.find_by_name name
    if right
      lv_before = right.lock_version
      right.send(:update_attributes, r)
      puts "| | Updated right [#{hyperlink} #{verb}] - #{r[:description]}" if lv_before != right.lock_version
    else
      puts "| | Creating right [#{hyperlink} #{verb}] - #{r[:description]}"
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


