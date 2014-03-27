json.authentication do |json|
	json.username    authentication.api_user.username
	json.user_id     authentication.api_user.id
	json.token       authentication.token
	json.max_age     authentication.max_age

  if @right
    if @right.is_a?(Right)
      @right = [{'app' => @right.app, 'context' => @right.context}]
    end
    json.right @right if @right != [{'app' => '*', 'context' => '*'}]
  end

  json.group_names authentication.api_user.groups.collect(&:name)
  json.created_at authentication.created_at.utc.iso8601
  json.expires_at authentication.expires_at.utc.iso8601
  json._links hyperlinks(
    self:    authentication_url(authentication.token),
    creator: api_user_url(authentication.api_user)
  )
end
