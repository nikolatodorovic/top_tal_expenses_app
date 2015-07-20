require 'jwt'

module AuthToken
  def AuthToken.issue_token(payload)
    payload[:exp] = Time.now.to_i + 4 * 3600
    JWT.encode payload, Rails.application.secrets.secret_key_base
  end

  def AuthToken.valid?(token)
    begin
      JWT.decode token, Rails.application.secrets.secret_key_base
    rescue
      false
    end
  end
end