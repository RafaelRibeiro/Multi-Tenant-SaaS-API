
class HealthController < ApplicationController
    def index
      ActiveRecord::Base.connection.execute("SELECT 1")

      render json: {
        status: "ok",
        application: "Multi-Tenant SaaS API",
        database: "connected",
        timestamp: Time.current.iso8601
      }, status: :ok
    rescue ActiveRecord::ActiveRecordError => e
      render json: {
        status: "error",
        database: "disconnected",
        message: e.message
      }, status: :service_unavailable
    end
  end
