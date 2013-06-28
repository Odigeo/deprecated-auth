class RolesController < ApplicationController

  ocean_resource_controller extra_actions: { 'api_users' => ['api_users', "GET"],
                                             'groups'    => ['groups',    "GET"],
                                             'rights'    => ["rights",    "POST"]}
 
  respond_to :json
 
  before_filter :find_role, :except => [:index, :create]
  before_filter :find_connectee, :only => [:connect, :disconnect]
  
    
  
  # GET /roles
  def index
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(collection_etag(Role))
      @roles = Role.index(params, params[:group], params[:search])
      render partial: "role", collection: @roles
    end
  end


  # GET /roles/1
  def show
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(@role)
      render partial: "role", object: @role
    end
  end


  # POST /roles
  def create
    @role = Role.new(filtered_params Role)
    set_updater(@role)
    if @role.valid?
      begin
        @role.save!
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, 
             SQLite3::ConstraintException 
        render_api_error 422, "Role already exists"
        return
      end
      render_new_resource @role, partial: "roles/role"
    else
      render_validation_errors @role
    end
  end


  # PUT /roles/1
  def update
    if missing_attributes?
      render_api_error 422, "Missing resource attributes"
      return
    end
    begin
      @role.assign_attributes(filtered_params Role)
      set_updater(@role)
      @role.save
    rescue ActiveRecord::StaleObjectError
      render_api_error 409, "Stale Role"
      return
    end
    if @role.valid?
      render partial: "role", object: @role
    else
      render_validation_errors(@role)
    end
  end


  # DELETE /roles/1
  def destroy
    @role.destroy
    render_head_204
  end


  # GET /roles/1/api_users
  def api_users
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(collection_etag(@role.api_users))
      render partial: "api_users/api_user", collection: @role.api_users
    end
  end


  # GET /roles/1/groups
  def groups
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(collection_etag(@role.groups))
      render partial: "groups/group", collection: @role.groups
    end
  end


  # GET /roles/1/rights
  def rights
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(collection_etag(@role.rights))
      render partial: "rights/right", collection: @role.rights
    end
  end

  
  # PUT /roles/1/connect
  def connect
    begin
      case @connectee_class.to_s
        when "ApiUser" then @role.api_users << @connectee
        when "Group"   then @role.groups << @connectee
        when "Right"   then @role.rights << @connectee
        else
          render_api_error 422, "Unsupported connection"
          return
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, SQLite3::ConstraintException
      # The connectee is already connected: do nothing.
    end
    @role.touch
    @connectee.touch
    render_head_204
  end


  # DELETE /roles/1/connect
  def disconnect
    case @connectee_class.to_s
      when "ApiUser" then @role.api_users.delete(@connectee)
      when "Group"   then @role.groups.delete(@connectee)
      when "Right"   then @role.rights.delete(@connectee)
      else
        render_api_error 422, "Unsupported connection"
        return
    end
    @role.touch
    @connectee.touch
    render_head_204
  end


  private

  def find_role
    @role = Role.find_by_id params[:id]
    return true if @role
    render_api_error 404, "Role not found"
    false
  end
  
end
