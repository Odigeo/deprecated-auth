class AuthenticationsController < ApplicationController

  ocean_resource_controller extra_actions: { 'creator' => ["creator", "GET"]},
                            required_attributes: []
  
  respond_to :json
  
  skip_before_action :require_x_api_token, except: [:index, :destroy]
  skip_before_action :authorize_action, only: [:create, :show]
  before_action :find_authentication, except: [:index, :create]
  before_action :find_api_user, only: :create
  
  #
  # POST /authentications
  # 
  # This action is used for authenticating an ApiUser.
  #
  def create
    max_age = @api_user.authentication_duration
    @authentication = Authentication.create!(:api_user => @api_user,
                                             :token => Authentication.new_token,
                                             :max_age => max_age,
                                             :created_at => Time.now.utc,
                                             :expires_at => Time.now.utc + max_age)
    logger.info "[#{@authentication.token}] Authentication CREATED for #{@api_user.username}"
    expires_now   # Tiny increase in security
    render partial: "authentication", object: @authentication, status: 201
  end

  
  # GET /authentications
  #
  # This action returns all active authentications.
  #
  def index
    # To simplify cache invalidation, Authentication collections are never cached.
    expires_in 0    
    if stale?(collection_etag(Authentication))
      @authentications = Authentication.index(params, params[:group], params[:search]).active
      render partial: "authentication", collection: @authentications
    end
  end
  
  
  #
  # GET /authentications/<token>?query=<query>
  # 
  # This action performs authorisation based on the token of a previous
  # Authentication.
  #
  def show
    username = @authentication.api_user.username
    token = @authentication.token
    # Has the authentication expired?
    if @authentication.expired?
      logger.info "[#{token}] Authentication EXPIRED for #{username}"
      expires_in 0, 's-maxage' => 1.day, 'max-stale' => 0
      render_api_error 400, "Re-authentication required"
      return
    end
    # Is the query string present?
    query = params[:query]
    if query.blank?
      expires_in 0, 's-maxage' => 1.day, 'max-stale' => 0
      render_api_error 422, "Query missing"
      return
    end
    # Is the query string well-formed?
    query = query.to_s.split(':')
    if query.length != 6
      expires_in 0, 's-maxage' => 1.day, 'max-stale' => 0
      render_api_error 422, "Malformed query string", 
                            "Must consist of exactly six colon-separated parts"
      return
    end
    # Is the verb a supported one?
    if !["*", "POST", "GET", "GET*", "PUT", "DELETE"].include?(query[3])
      expires_in 0, 's-maxage' => 1.day, 'max-stale' => 0
      render_api_error 422, "Malformed query string", 
                            "Unsupported verb"
      return
    end
    # Is the client authorised to perform the query?
    if !@authentication.authorized?(*query)
      logger.info "[#{token}] Authorization DENIED: #{username} may NOT <#{params[:query]}>"
      expires_in 0, 's-maxage' => 1.day, 'max-stale' => 0
      render_api_error 403, "Denied"
      return
    end
    # Let the authorisation live in the Varnish cache while it's valid
    if stale?(last_modified: @authentication.created_at, etag: @authentication)
      smax_age = @authentication.seconds_remaining
      logger.info "[#{token}] Authorization GRANTED: #{username} may <#{params[:query]}> for #{smax_age}s"
      expires_in 0, 's-maxage' => smax_age, 'max-stale' => 0
      render partial: "authentication", object: @authentication
    end
  end
  
  
  #
  # DELETE /authentications/<token>
  # 
  # This action revokas an authentication and all its authorisations.
  #
  def destroy
    user = @authentication.api_user
    @authentication.destroy
    logger.info "[#{@authentication.token}] Authentication DESTROYED for #{user.username} "
    render_head_204    
  end


  def creator
    render partial: "api_users/api_user", object: @authentication.api_user
  end
  
  
  private
  
  def find_authentication
    @authentication = Authentication.find_by_token(params[:id])
    return true if @authentication
    logger.info "Authentication not found for [#{params[:id]}]"
    expires_in 0, 's-maxage' => 1.day, 'max-stale' => 0
    render_api_error 400, "Authentication not found"
    false
  end  

  def find_api_user
    username, password = Api.decode_credentials(request.headers['X-API-Authenticate'])
    if username == "" && password == ""
      logger.info "Authentication with malformed credentials for #{username}"
      expires_in 1.hour
      render_api_error 400, "Malformed credentials"
      return false
    end
    return true if (@api_user = ApiUser.find_by_credentials(username, password))
    logger.info "Authentication doesn't authenticate for #{username}"
    render_api_error 403, "Does not authenticate"
    false
  end
        
end
