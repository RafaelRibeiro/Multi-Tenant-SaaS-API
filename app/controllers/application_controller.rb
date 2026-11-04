class ApplicationController < ActionController::API
  include Pundit::Authorization

  around_action :reset_current_attributes

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def reset_current_attributes
    Current.reset

    yield
  ensure
    Current.reset
  end

  def user_not_authorized
    render json: {
      error: "Access denied"
    }, status: :forbidden
  end
end