class ResourcesController < ApplicationController

  ocean_resource_controller extra_actions: { 'rights'       => ['rights', "GET"],
                                             'right_create' => ["rights", "POST"]}

  respond_to :json

  before_action :find_resource, except: [:index, :create]
  
  
  
  # GET /resources
  def index
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(collection_etag(Resource))
      @resources = Resource.collection(params)
      api_render @resources
    end
  end


  # GET /resources/1
  def show
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(@resource)
      api_render @resource
    end
  end


  # POST /resources
  #
  # The create action for resources is not supported. To create a resource,
  # you should make a POST to the "resources" hyperlink of the Service resource
  # it should belong to. This is the pattern used for all parented HATEOAS
  # relations.


  # PUT /resources/1
  def update
    if missing_attributes?
      render_api_error 422, "Missing resource attributes"
      return
    end
    begin
      @resource.assign_attributes(filtered_params Resource)
      set_updater(@resource)
      @resource.save
    rescue ActiveRecord::StaleObjectError
      render_api_error 409, "Stale Resource"
      return
    end
    if @resource.valid?
      api_render @resource
    else
      render_validation_errors(@resource)
    end
  end


  # DELETE /resources/1
  def destroy
    @resource.destroy
    render_head_204
  end


  # GET /resources/1/rights
  def rights
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(collection_etag(@resource.rights))
      api_render @resource.rights
    end
  end
  

  # POST /resources/1/rights
  def right_create
    @right = @resource.rights.new(filtered_params Right)
    set_updater(@right)
    if @right.valid?
      begin
        @right.save!
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, 
             SQLite3::ConstraintException 
        render_api_error 422, "Right already exists"
        return
      end
      api_render @right, new: true
    else
      render_validation_errors @right
    end
  end

  
  private
     
  def find_resource
    @resource = Resource.find_by_id params[:id]
    return true if @resource
    render_api_error 404, "Resource not found"
    false
  end
  
end
