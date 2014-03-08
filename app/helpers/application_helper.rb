module ApplicationHelper

  #
  # Used in Jbuilder templates to build hyperlinks
  #
  def hyperlinks(links={})
    result = {}
    links.each do |qi, val|
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
  
end
