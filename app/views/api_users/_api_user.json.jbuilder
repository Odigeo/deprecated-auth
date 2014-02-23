json.api_user do |json|
	json.username                  api_user.username
	json.real_name                 api_user.real_name
	json.email                     api_user.email
	json.authentication_duration   api_user.authentication_duration
	json.login_blocked             api_user.login_blocked
	json.login_blocked_reason      api_user.login_blocked_reason if api_user.login_blocked_reason.present?
	json.created_at                api_user.created_at.utc.iso8601
	json.updated_at                api_user.updated_at.utc.iso8601
	json.lock_version              api_user.lock_version
	json.indestructible            api_user.indestructible if api_user.indestructible
	json._links hyperlinks(
	  self:            api_user_url(api_user),
	  authentications: authentications_api_user_url(api_user),
	  roles:           roles_api_user_url(api_user),
	  groups:          groups_api_user_url(api_user),
	  connect:         connect_api_user_url(api_user),
	  creator:         api_user_url(id: api_user.created_by || 0),
	  updater:         api_user_url(id: api_user.updated_by || 0)
	)
end
