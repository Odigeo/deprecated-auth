class BasicBanObserver < ActiveRecord::Observer

  observe :api_user, :group, :resource, :right, :role, :service
 

  def after_create(model)
    resource_name = model.class.name.pluralize.underscore
    v = model.class.latest_api_version
    Api.ban "/#{v}/#{resource_name}"
  end


  def after_update(model)
    resource_name = model.class.name.pluralize.underscore
    v = model.class.latest_api_version
    Api.ban "/#{v}/#{resource_name}"
    Api.ban "/#{v}/#{resource_name}/#{model.id}"
    Api.ban "/#{v}/#{resource_name}/#{model.id}/", true
  end
  
  
  def after_touch(model)
    after_update(model)
  end
    

  def after_destroy(model)
    after_update(model)
  end

end
