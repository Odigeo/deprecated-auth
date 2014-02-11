#
# The path /cleanup is implemented solely for the benefit of the cleanup cron task.
# It can never be reached from the outside.
#

class CleanupController < ApplicationController
  
  skip_before_action :require_x_api_token
  skip_before_action :authorize_action


  def update
    sleep rand(60)
    n = Authentication.count
    Authentication.old_expired.destroy_all
    logger.info "Cleaned up #{n - Authentication.count} old expired Authentications"
    render_head_204
  end
  
end
