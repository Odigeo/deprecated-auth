class ApiUsersController < ApplicationController

  ocean_resource_controller required_attributes: [:username, :real_name, :email, :lock_version],
                            no_validation_errors_on: [:password_hash, :password_salt],
                            extra_actions: { 'authentications' => ['authentications', "GET"],
                                             'roles'           => ['roles', "GET"],
                                             'groups'          => ['groups', "GET"]}
                            
  respond_to :json

  before_action :find_api_user, :except => [:index, :create]
  before_action :find_connectee, :only => [:connect, :disconnect]
  
  
  # GET /api_users
  def index
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(collection_etag(ApiUser))
      @api_users = ApiUser.collection(params)
      api_render @api_users
    end
  end


  # GET /api_users/1
  def show
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(@api_user)
      api_render @api_user
    end
  end


  # POST /api_users
  def create
    @api_user = ApiUser.new(filtered_params ApiUser)
    set_updater(@api_user)
    @api_user.save!
    logger.info "New ApiUser #{@api_user.id} (#{params[:username]}, #{params[:real_name]}) created"
    api_render @api_user, new: true
  end


  # PUT /api_users/1
  def update
    if missing_attributes?
      render_api_error 422, "Missing resource attributes"
      return
    end
    @api_user.assign_attributes(filtered_params ApiUser)
    set_updater(@api_user)
    @api_user.save!
    api_render @api_user
  end


  # DELETE /api_users/1
  def destroy
    render_api_error 403, "Indestructible" and return if @api_user.indestructible
    @api_user.destroy
    logger.info "ApiUser #{@api_user.username} (#{@api_user.real_name}) destroyed"
    render_head_204
  end


  # GET /api_users/1/authentications
  def authentications
    api_render @api_user.authentications
  end
  
  
  # GET /api_users/1/roles
  def roles
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(collection_etag(@api_user.roles))
      api_render @api_user.roles
    end
  end
  
  
  # GET /api_users/1/groups
  def groups
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(collection_etag(@api_user.groups))
      api_render @api_user.groups
    end
  end


  # PUT /api_users/1/connect
  def connect
    begin
      case @connectee_class.to_s
        when "Group" then @api_user.groups << @connectee
        when "Role"  then @api_user.roles << @connectee
        else
          render_api_error 422, "Unsupported connection"
          return
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, SQLite3::ConstraintException
      # The connectee is already connected: do nothing.
    end
    @api_user.touch
    @connectee.touch
    render_head_204
  end


  # DELETE /api_users/1/connect
  def disconnect
    case @connectee_class.to_s
      when "Group" then @api_user.groups.delete(@connectee)
      when "Role"  then @api_user.roles.delete(@connectee)
      else
        render_api_error 422, "Unsupported connection"
        return
    end
    @api_user.touch
    @connectee.touch
    render_head_204
  end


  private

  def find_api_user
    @api_user = ApiUser.find_by_id params[:id]
    return true if @api_user
    render_api_error 404, "ApiUser not found"
    false
  end
    
end
