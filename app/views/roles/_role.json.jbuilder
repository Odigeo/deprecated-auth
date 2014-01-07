json.role do |json|
	json.(role, :name, :description, :lock_version) 
	json.created_at     role.created_at.utc.iso8601
	json.updated_at     role.updated_at.utc.iso8601
	json.indestructible role.indestructible if role.indestructible
	json._links hyperlinks(
	  self:      role_url(role),
	  api_users: api_users_role_url(role),
	  groups:    groups_role_url(role),
	  rights:    rights_role_url(role),
	  connect:   connect_role_url(role),
	  creator:   api_user_url(id: role.created_by || 0),
	  updater:   api_user_url(id: role.updated_by || 0)
	)
end
