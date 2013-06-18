json.right do |json|
	json._links  hyperlinks(self:     right_url(right),
	                        resource: resource_url(right.resource),
	                        service:  service_url(right.service),
	                        connect:  connect_right_url(right),
	                        creator: api_user_url(id: right.created_by || 0),
	                        updater: api_user_url(id: right.updated_by || 0))
	json.(right, :name, 
				 :description,
	             :lock_version,
	             :hyperlink, 
	             :verb, 
	             :app, 
	             :context) 
	json.created_at right.created_at.utc.iso8601
	json.updated_at right.updated_at.utc.iso8601
end
