module ApplicationHelper

  #
  # Used in Jbuilder templates to build hyperlinks
  #
  def hyperlinks(links={})
    result = {}
    links.each do |qi, val|
      next unless val
      result[qi.to_s] = { 
                 "href" => val.kind_of?(String) ? val : val[:href], 
                 "type" => val.kind_of?(String) ? "application/json" : val[:type]
              }
    end
    result
  end


  def instances_url(chef_env: CHEF_ENV, service: null)
    "#{OCEAN_API_URL}/#{Api.version_for :instances}/instances?chef_env=#{chef_env}&service=#{service}"
  end
  

  #
  # View helper predicates to determine if the ApiUser behind the current
  # authorisation belongs to one or more of a list of Groups.
  #
  def member_of_group?(*names)
    @group_names && @group_names.intersect?(names.to_set) 
  end

  #
  # Returns true if the ApiUser behind the current authorisation belongs 
  # to the Ocean Group "Superusers".
  #
  def superuser?
    member_of_group?("Superusers")
  end
end
