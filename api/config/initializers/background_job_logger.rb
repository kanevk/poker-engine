ActiveSupport::Notifications.subscribe "enqueue_retry.active_job" do |*args|
  event = ActiveSupport::Notifications::Event.new *args
  payload = event.payload
  job = payload[:job]
  error = payload[:error]
  message = "#{job.class} (JID #{job.job_id})
             with arguments #{job.arguments.join(', ')}
             will be retried again in #{payload[:wait]}s
             due to error '#{error.class} - #{error.message}'.
             It is executed #{job.executions} times so far.".squish

  BackgroundJob::Logger.log(message)
end
