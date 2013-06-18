json.api_user do |json|
	json._links       hyperlinks(self:            api_user_url(api_user),
	                             authentications: authentications_api_user_url(api_user),
	                             roles:           roles_api_user_url(api_user),
	                             groups:          groups_api_user_url(api_user),
	                             connect:         connect_api_user_url(api_user),
	                             creator:         api_user_url(id: api_user.created_by || 0),
	                             updater:         api_user_url(id: api_user.updated_by || 0))
	json.username     api_user.username
	json.real_name    api_user.real_name
	json.email        api_user.email
	json.created_at   api_user.created_at.utc.iso8601
	json.updated_at   api_user.updated_at.utc.iso8601
	json.lock_version api_user.lock_version
end
