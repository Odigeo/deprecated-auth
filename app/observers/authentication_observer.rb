class AuthenticationObserver < ActiveRecord::Observer
 
  def after_destroy(model)
   	resource_name = model.class.name.pluralize.underscore
   	#puts "Destroyed #{resource_name}"
    Api.ban "/v1/#{resource_name}/#{model.token}"
  end

end
