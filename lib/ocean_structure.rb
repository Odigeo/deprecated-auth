#
# Process any rights
#
def process_rights(target, list, exclusive)
  before = target.rights.clone
  expanded = []
  (list || []).each do |x|
    if x.is_a?(Hash) && x['regexp']
      Right.all.each do |r|
        expanded << r if r.name =~ Regexp.new(x['regexp'])
      end
    else
      r = Right.find_by_name x
      expanded << r if r
    end
  end
  expanded.each do |r|
    if target.rights.include?(r)
      puts "| #{r.name} is already part of the role"
    else
      target.rights << r
      puts "| Added #{r.name}"
    end
  end
  if exclusive
    (before - expanded).each do |r|
      puts "| Deleted #{r.name}"
    end
  end
end


#
# Process any api_users
#
def process_api_users(target, list)
  (list || []).each do |username|
    u = ApiUser.find_by_username username
    puts "| Couldn't add non-existent ApiUser #{username}" and next unless u
    if target.api_users.include?(u)
      puts "| The #{username} ApiUser already belongs to the #{target.name} group"
    else
      target.api_users << u
      puts "| The #{username} ApiUser now belongs to the #{target.name} group"
    end
  end
end


#
# Process any roles
#
def process_roles(target, list)
  (list || []).each do |rolename|
    r = Role.find_by_name rolename
    puts "| Couldn't add non-existent Role #{rolename}" and next unless r
    if target.roles.include?(r)
      puts "| The #{rolename} Role already is part of the #{target.name} group"
    else
      target.roles << r
      puts "| The #{rolename} Role is now part of the #{target.name} group"
    end
  end
end
