module AuthToken
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  def self.encode(user_id:, exp: 24.hours.from_now.to_i)
    JWT.encode({ user_id: user_id, exp: exp }, SECRET_KEY)
  end

  def self.decode(token)
    JWT.decode(token, SECRET_KEY)[0].symbolize_keys
  rescue JWT::InvalidIssuerError
    return {}
  end
end
