json.group do |json|
	json.(group, :name, :description, :lock_version)
	json.created_at     group.created_at.utc.iso8601
	json.updated_at     group.updated_at.utc.iso8601
	json.indestructible group.indestructible if group.indestructible
	json._links hyperlinks(
	  self:      group_url(group),
      documentation: group.documentation_href.present? && 
                     {href: group.documentation_href, 
                      type: "text/html"},
	  api_users: api_users_group_url(group),
	  roles:     roles_group_url(group),
	  rights:    rights_group_url(group),
	  connect:   connect_group_url(group),
	  creator:   api_user_url(id: group.created_by || 0),
	  updater:   api_user_url(id: group.updated_by || 0)
	)
end
