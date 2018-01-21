require 'bundler/setup'

Bundler.require(:default, :development)

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
end
