module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    header = request.headers["Authorization"]

    token = header&.match(/\ABearer\s+(.+)\z/i)&.captures&.first

    return render_unauthorized unless token

    decoded_token = JsonWebToken.decode(token)

    @current_user = User.find_by(id: decoded_token["sub"])

    render_unauthorized unless @current_user
  rescue JsonWebToken::DecodeError
    render_unauthorized
  end

  def current_user
    @current_user
  end

  def render_unauthorized
    render json: {
      error: "Unauthorized"
    }, status: :unauthorized
  end
end