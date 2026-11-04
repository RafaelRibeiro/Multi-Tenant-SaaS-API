module Api
  module V1
    class ProtectedController < ApplicationController
      include Authentication

      def show
        render json: {
          message: "Authenticated successfully",
          user_id: current_user.id
        }
      end
    end
  end
end