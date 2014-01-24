class RolesController < ApplicationController

  ocean_resource_controller extra_actions: { 'api_users' => ['api_users', "GET"],
                                             'groups'    => ['groups',    "GET"],
                                             'rights'    => ["rights",    "POST"]}
 
  respond_to :json
 
  before_action :find_role, :except => [:index, :create]
  before_action :find_connectee, :only => [:connect, :disconnect]
  
    
  
  # GET /roles
  def index
    expires_in 0, 's-maxage' => 1.week
    if stale?(collection_etag(Role))
      @roles = Role.collection(params)
      api_render @roles
    end
  end


  # GET /roles/1
  def show
    expires_in 0, 's-maxage' => 1.week
    if stale?(@role)
      api_render @role
    end
  end


  # POST /roles
  def create
    @role = Role.new(filtered_params Role)
    set_updater(@role)
    @role.save!
    api_render @role, new: true
  end


  # PUT /roles/1
  def update
    if missing_attributes?
      render_api_error 422, "Missing resource attributes"
      return
    end
    @role.assign_attributes(filtered_params Role)
    set_updater(@role)
    @role.save!
    api_render @role
  end


  # DELETE /roles/1
  def destroy
    render_api_error 403, "Indestructible" and return if @role.indestructible
    @role.destroy
    render_head_204
  end


  # GET /roles/1/api_users
  def api_users
    expires_in 0, 's-maxage' => 1.week
    if stale?(collection_etag(@role.api_users))
      api_render @role.api_users
    end
  end


  # GET /roles/1/groups
  def groups
    expires_in 0, 's-maxage' => 1.week
    if stale?(collection_etag(@role.groups))
      api_render @role.groups
    end
  end


  # GET /roles/1/rights
  def rights
    expires_in 0, 's-maxage' => 1.week
    if stale?(collection_etag(@role.rights))
      api_render @role.rights
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
