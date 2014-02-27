class AuthenticationsController < ApplicationController

  ocean_resource_controller required_attributes: []
  
  respond_to :json
  
  skip_before_action :require_x_api_token, only: [:create, :show]
  skip_before_action :authorize_action,    only: [:create, :show]

  before_action :find_authentication,      only: [:show, :destroy]
  before_action :find_api_user,            only: :create
  before_action :ensure_not_blocked,       only: :create
  
  
  #
  # POST /authentications
  # 
  # This action is used for authenticating an ApiUser.
  #
  def create
    # Is there an active authentication we can use?
    @authentication = @api_user.authentications.order(:expires_at).last
    max_age = @api_user.authentication_duration
    if @authentication
      @authentication.update_attributes(expires_at: Time.now.utc + max_age)
    else
      @authentication = Authentication.create!(:api_user => @api_user,
                                               :token => Authentication.new_token,
                                               :max_age => max_age,
                                               :created_at => Time.now.utc,
                                               :expires_at => Time.now.utc + max_age)
    end
    Thread.current[:username] = @api_user.username
    Thread.current[:x_api_token] = @authentication.token
    #logger.info "Authentication CREATED for #{@api_user.username}"
    expires_now   # Tiny increase in security
    render partial: "authentication", object: @authentication, status: 201
  end

  
  #
  # GET /authentications/<token>?query=<query>
  # 
  # This action performs authorisation based on the token of a previous
  # Authentication.
  #
  def show
    logger.info "X-Forwarded-For: #{request.headers['X-Forwarded-For']}"
    username = @authentication.api_user.username
    token = @authentication.token
    Thread.current[:username] = username
    Thread.current[:x_api_token] = token
    # Has the authentication expired?
    if @authentication.expired?
      logger.info "Authentication EXPIRED for #{username}"
      expires_now  # We're re-using authentications
      render_api_error 419, "Authentication Timeout"
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
      logger.warn "Authorization DENIED: #{username} may NOT <#{params[:query]}>"
      expires_in 0, 's-maxage' => 5.seconds, 'max-stale' => 0
      render_api_error 403, "Denied"
      return
    end
    # Let the authorisation live in the Varnish cache while it's valid
    if stale?(last_modified: @authentication.created_at, etag: @authentication)
      #smax_age = @authentication.seconds_remaining
      #logger.info "Authorization GRANTED: #{username} may <#{params[:query]}> for #{smax_age}s"
      expires_in 0, 's-maxage' => AUTHORIZATION_DURATION, 'max-stale' => 0
      api_render @authentication
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
    logger.info "Authentication DESTROYED for #{user.username} [#{@authentication.token}]"
    render_head_204    
  end


  private
  
  def find_authentication
    # TODO: Eliminate find_by_token, eager load the ApiUser.
    @authentication = Authentication.find_by_token(params[:id])
    if @authentication
      Thread.current[:username] = @authentication.api_user.username
      Thread.current[:token] = @authentication.token
      return true 
    end
    logger.info "Authentication not found for [#{params[:id]}]"
    expires_in 0, 's-maxage' => 1.day, 'max-stale' => 0
    render_api_error 400, "Authentication not found"
    false
  end  

  def find_api_user
    username, password = Api.decode_credentials(request.headers['X-API-Authenticate'])
    if username == "" && password == ""
      logger.info "Authentication with malformed credentials for #{username}"
      expires_in 0, 's-maxage' => 1.day, 'max-stale' => 0
      render_api_error 400, "Malformed credentials"
      return false
    end
    @api_user = ApiUser.find_by_credentials(username, password)
    unless @api_user
      logger.warn "Authentication doesn't authenticate for #{username}"
      expires_in 0, 's-maxage' => 10.seconds, 'max-stale' => 0
      render_api_error 403, "Does not authenticate"
      return false
    end
    true
  end

  def ensure_not_blocked
    return true unless @api_user.login_blocked
    logger.warn "Login blocked for #{@api_user.username}: \"#{@api_user.login_blocked_reason}\""
    expires_in 0, 's-maxage' => 10.seconds, 'max-stale' => 0
    res = ["Login blocked"]
    res << @api_user.login_blocked_reason if @api_user.login_blocked_reason.present?
    render_api_error 403, *res
    false
  end
        
end
