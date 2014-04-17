#
# The path /cleanup is implemented solely for the benefit of the cleanup cron task.
# It can never be reached from the outside.
#

class CleanupController < ApplicationController
  
  skip_before_action :require_x_api_token
  skip_before_action :authorize_action


  def update
    n = Authentication.count
    return if n == 0
    sleep rand(10) unless Rails.env == 'test'
    n = Authentication.count
    return if n == 0
    killed = 0
    t = (Time.now - EXPIRED_AUTHENTICATION_LIFE).utc
    Authentication.find_each do |auth|
      auth.destroy if auth.expires_at.utc <= t
      killed += 1
      sleep 0.1
    end
    logger.info "Cleaned up #{killed} old expired Authentications"
    render_head_204
  end
  
end
