module ApplicationCable
  class Connection < ActionCable::Connection::Base
    def connect
      Rails.logger.info("Auth #{request.authorization.to_s}")
    end
  end
end
