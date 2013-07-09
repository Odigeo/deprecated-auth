class AuthenticationObserver < ActiveRecord::Observer
 
  def after_destroy(model)
   	resource_name = model.class.name.pluralize.underscore
    v = model.class.latest_api_version
   	#puts "Destroyed #{resource_name}"
    Api.ban "/v#{v}/#{resource_name}/#{model.token}", true
    # Authentication collections are never cached, thus no need to invalidate them.
  end

end
