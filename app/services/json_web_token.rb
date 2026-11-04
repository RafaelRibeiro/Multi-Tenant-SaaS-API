class JsonWebToken
  ALGORITHM = "HS256"
  EXPIRATION_TIME = 24.hours

  class DecodeError < StandardError; end

  def self.encode(payload, exp = EXPIRATION_TIME.from_now)
    payload = payload.merge(exp: exp.to_i)

    JWT.encode(
      payload,
      secret_key,
      ALGORITHM
    )
  end

  def self.decode(token)
    decoded = JWT.decode(
      token,
      secret_key,
      true,
      algorithm: ALGORITHM
    )

    decoded.first
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError => e
    raise DecodeError, e.message
  end

  def self.secret_key
    ENV.fetch("JWT_SECRET_KEY")
  end

  private_class_method :secret_key
end