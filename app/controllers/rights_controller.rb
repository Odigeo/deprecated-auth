class RightsController < ApplicationController

  ocean_resource_controller extra_actions: { 'groups'   => ["groups",   "GET"],
                                             'roles'    => ["roles",    "GET"]},
                            required_attributes: [:lock_version, :description, 
                                                  :hyperlink, :verb, :app, :context]

  respond_to :json
  
  before_action :find_right, except: :index
  before_action :find_connectee, only: [:connect, :disconnect]
  
  
  
  # GET /rights
  def index
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(collection_etag(Right))
      @rights = Right.collection(params)
      api_render @rights
    end
  end


  # GET /rights/1
  def show
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(@right)
      api_render @right
    end
  end


  # # POST /rights
  #
  # The create action for rights is not supported. To create a right,
  # you should make a POST to the "rights" hyperlink of the Resource resource
  # it should belong to. This is the pattern used for all parented HATEOAS
  # relations.


  # PUT /rights/1
  def update
    if missing_attributes?
      render_api_error 422, "Missing resource attributes"
      return
    end
    @right.assign_attributes(filtered_params Right)
    set_updater(@right)
    @right.save!
    api_render @right
  end


  # DELETE /rights/1
  def destroy
    @right.destroy
    render_head_204
  end


  # GET /rights/1/groups
  def groups
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(collection_etag(Group))
      api_render @right.groups
    end
  end


  # GET /rights/1/roles
  def roles
    expires_in 0, 's-maxage' => DEFAULT_CACHE_TIME
    if stale?(collection_etag(@right.roles))
      api_render @right.roles
    end
  end

  
  # PUT /rights/1/connect
  def connect
    begin
      case @connectee_class.to_s
        when "Group" then @right.groups << @connectee
        when "Role"  then @right.roles << @connectee
        else
          render_api_error 422, "Unsupported connection"
          return
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, SQLite3::ConstraintException
      # The connectee is already connected: do nothing.
    end
    @right.touch
    @connectee.touch
    render_head_204
  end


  # DELETE /rights/1/connect
  def disconnect
    case @connectee_class.to_s
      when "Group" then @right.groups.delete(@connectee)
      when "Role"  then @right.roles.delete(@connectee)
      else
        render_api_error 422, "Unsupported connection"
        return
    end
    @right.touch
    @connectee.touch
    render_head_204
  end


  private

  def find_right
    @right = Right.find_by_id params[:id]
    return true if @right
    render_api_error 404, "Right not found"
    false
  end
  
end
