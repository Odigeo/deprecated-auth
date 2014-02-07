require 'pp'

ActiveSupport::Notifications.subscribe "halted_callback.action_controller" do |*args|
  data = args.extract_options!
  Thread.current[:filter] = data[:filter]
end


INTERNAL_PARAMS = %w(controller action format _method only_path)

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, started, finished, unique_id, payload|

  path = payload[:path]
  if path  != '/alive'

    runtime = finished - started
    param_method = payload[:params]['_method']
    method = param_method ? param_method.upcase : payload[:method]
    status = compute_status(payload)
    params = payload[:params].except(*INTERNAL_PARAMS)

    data = {
      timestamp:    (started.utc.to_f * 1000).to_i,
      method:       method,
      status:       status,
      runtime:      runtime * 1000,
      view_runtime: payload[:view_runtime],
      db_runtime:   payload[:db_runtime]
    }
    data[:params] = params if params.present?
    data[:filter] = Thread.current[:filter] if Thread.current[:filter]

    Thread.current[:logdata] = data
  end
end

def compute_status payload
  status = payload[:status]
  if status.nil? && payload[:exception].present?
    exception_class_name = payload[:exception].first
    status = ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)
  end
  status
end


ActiveSupport::Notifications.subscribe 'request.action_dispatch' do |*args|
  x = args.extract_options!
  request = x[:request]
  response = request.env["action_controller.instance"].response
  data = Thread.current[:logdata]
  data[:remote_ip] = request.remote_ip
  data[:path] = request.filtered_path
  data[:_api_error] = JSON.parse(response.body)['_api_error'] if response.body =~ /\A\{"_api_error"/

  ex = request.env["action_dispatch.exception"]
  if ex && data[:status] != 404
    # We might want to send an email here - exceptions in production
    # should be taken seriously
    data[:exception_message] = ex.message
    data[:exception_backtrace] = ex.backtrace.to_json
  end

  pp data
  # Rails.logger.info data
end

