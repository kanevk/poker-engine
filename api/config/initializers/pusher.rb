PUSHER = Pusher::Client.new(
  app_id: '1075445',
  key: '058b4766a9814309c004',
  secret: '***REMOVED***',
  cluster: 'eu',
  encrypted: true
)

Pusher.logger = Rails.logger
