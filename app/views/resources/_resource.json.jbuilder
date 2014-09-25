json.resource do |json|
	json.(resource, :name, :description, :lock_version) 
	json.created_at resource.created_at.utc.iso8601
	json.updated_at resource.updated_at.utc.iso8601
	json._links hyperlinks(
	  self:          resource_url(resource),
	  service:       service_url(resource.service),
	  rights:        rights_resource_url(resource),
	  documentation: resource.documentation_href.present? && 
	                 {href: resource.documentation_href, 
	                  type: "text/html"},
	  creator: api_user_url(id: resource.created_by || 0),
	  updater: api_user_url(id: resource.updated_by || 0)
	)
end
