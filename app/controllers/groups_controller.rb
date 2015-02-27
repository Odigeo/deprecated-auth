class GroupsController < ApplicationController

  ocean_resource_controller extra_actions: { 'api_users' => ['api_users', "GET"],
                                             'roles'     => ['roles', "GET"],
                                             'rights'    => ['rights', "GET"]}

  before_action :find_group, :except => [:index, :create]
  before_action :find_connectee, :only => [:connect, :disconnect]
 
  
  
  # GET /groups
  def index
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(collection_etag(Group))
      @groups = Group.collection(params)
      api_render @groups
    end
  end


  # GET /groups/1
  def show
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(@group)
      api_render @group
    end
  end


  # POST /groups
  def create
    @group = Group.new(filtered_params Group)
    set_updater(@group)
    @group.save!
    api_render @group, new: true
  end


  # PUT /groups/1
  def update
    if missing_attributes?
      render_api_error 422, "Missing resource attributes"
      return
    end
    @group.assign_attributes(filtered_params Group)
    set_updater(@group)
    @group.save!
    api_render @group
  end


  # DELETE /groups/1
  def destroy
    render_api_error 403, "Indestructible" and return if @group.indestructible
    @group.destroy
    render_head_204
  end


  # GET /groups/1/api_users
  def api_users
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(collection_etag(@group.api_users))
      api_render @group.api_users
    end
  end


  # GET /groups/1/roles
  def roles
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(collection_etag(@group.roles))
      api_render @group.roles
    end
  end


  # GET /groups/1/rights
  def rights
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(collection_etag(@group.rights))
      api_render @group.rights
    end
  end

  
  # PUT /groups/1/connect
  def connect
    begin
      case @connectee_class.to_s
        when "ApiUser" then @group.api_users << @connectee
        when "Role"    then @group.roles << @connectee
        when "Right"   then @group.rights << @connectee
        else
          render_api_error 422, "Unsupported connection"
          return
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, SQLite3::ConstraintException
      # The connectee is already connected: do nothing.
    end
    @group.touch
    @connectee.touch
    render_head_204
  end


  # DELETE /groups/1/connect
  def disconnect
    case @connectee_class.to_s
      when "ApiUser" then @group.api_users.delete(@connectee)
      when "Role"    then @group.roles.delete(@connectee)
      when "Right"   then @group.rights.delete(@connectee)
      else
        render_api_error 422, "Unsupported connection"
        return
    end
    @group.touch
    @connectee.touch
    render_head_204
  end


  private
     
  def find_group
    @group = Group.find_by_id params[:id]
    return true if @group
    render_api_error 404, "Group not found"
    false
  end  
  
end
