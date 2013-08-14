class ServicesController < ApplicationController

  ocean_resource_controller extra_actions: { 'resources'       => ['resources', "GET"],
                                             'resource_create' => ['resources', "POST"]}
  
  respond_to :json

  before_action :find_service, except: [:index, :create]
  
  
  
  # GET /services
  def index
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(collection_etag(Service))
      @services = Service.collection(params)
      api_render @services
    end
  end


  # GET /services/1
  def show
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(@service)
      api_render @service
    end
  end


  # POST /services
  def create
    @service = Service.new(filtered_params Service)
    set_updater(@service)
    @service.save!
    api_render @service, new: true
  end


  # PUT /services/1
  def update
    if missing_attributes?
      render_api_error 422, "Missing resource attributes"
      return
    end
    @service.assign_attributes(filtered_params Service)
    set_updater(@service)
    @service.save!
    api_render @service
  end


  # DELETE /services/1
  def destroy
    @service.destroy
    render_head_204
  end


  # GET /services/1/resources
  def resources
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(collection_etag(@service.resources))
      api_render @service.resources
    end
  end


  # POST /services/1/resources
  def resource_create
    @resource = @service.resources.build(filtered_params Resource)
    set_updater(@resource)
    @resource.save!
    api_render @resource, new: true
  end

  
  
  private

  def find_service
    @service = Service.find_by_id params[:id]
    return true if @service
    render_api_error 404, "Service not found"
    false
  end
  
end
