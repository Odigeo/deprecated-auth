class ServicesController < ApplicationController

  ocean_resource_controller extra_actions: { 'resources'       => ['resources', "GET"],
                                             'resource_create' => ['resources', "POST"]}
  
  respond_to :json

  before_action :find_service, except: [:index, :create]
  
  
  
  # GET /services
  def index
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(collection_etag(Service))
      @services = Service.index(params, params[:group], params[:search])
      render partial: "service", collection: @services
    end
  end


  # GET /services/1
  def show
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(@service)
      render partial: "service", object: @service
    end
  end


  # POST /services
  def create
    @service = Service.new(filtered_params Service)  # Init here
    set_updater(@service)
    if @service.valid?
      begin
        @service.save!
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, 
             SQLite3::ConstraintException 
        render json: {_api_error: ["Service already exists"]}, :status => 422 
        return
      end
      render_new_resource @service, partial: "services/service"
    else
      render_validation_errors @service
    end
  end


  # PUT /services/1
  def update
    if missing_attributes?
      render_api_error 422, "Missing resource attributes"
      return
    end
    begin
      @service.assign_attributes(filtered_params Service)
      set_updater(@service)
      @service.save
    rescue ActiveRecord::StaleObjectError
      render_api_error 409, "Stale Service"
      return
    end
    if @service.valid?
      render partial: "service", object: @service
    else
      render_validation_errors(@service)
    end
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
      render partial: "resources/resource", collection: @service.resources
    end
  end


  # POST /services/1/resources
  def resource_create
    @resource = @service.resources.build(filtered_params Resource)
    set_updater(@resource)
    if @resource.valid?
      begin
        @resource.save!
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, 
             SQLite3::ConstraintException 
        render json: {_api_error: ["Resource already exists"]}, :status => 422 
        return
      end
      render_new_resource @resource, partial: "resources/resource"
    else
      render_validation_errors @resource
    end
  end

  
  
  private

  def find_service
    @service = Service.find_by_id params[:id]
    return true if @service
    render_api_error 404, "Service not found"
    false
  end
  
end
