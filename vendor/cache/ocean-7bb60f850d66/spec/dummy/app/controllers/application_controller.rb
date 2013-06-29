class ApplicationController < ActionController::Base

  include OceanApplicationController

  before_filter :require_x_api_token
  before_filter :authorize_action

end
