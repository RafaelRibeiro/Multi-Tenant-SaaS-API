module Api
  module V1
    class AuthController < ApplicationController
      def login
        user = User.find_by(email: params[:email]&.strip&.downcase)

        unless user&.authenticate(params[:password])
          return render json: {
            error: "Invalid email or password"
          }, status: :unauthorized
        end

        token = JsonWebToken.encode(sub: user.id)

        render json: {
          token: token,
          token_type: "Bearer",
          expires_in: JsonWebToken::EXPIRATION_TIME.to_i
        }, status: :ok
      end
    end
  end
end