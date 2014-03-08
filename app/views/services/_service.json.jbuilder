json.service do |json|
	json.(service, :name, :description, :lock_version) 
	json.created_at service.created_at.utc.iso8601
	json.updated_at service.updated_at.utc.iso8601
  json._links hyperlinks(
    self:      service_url(service),
    resources: resources_service_url(service),
    instances: instances_url(chef_env: CHEF_ENV, service: service.name),
    creator:   api_user_url(id: service.created_by || 0),
    updater:   api_user_url(id: service.updated_by || 0)
  )
end
