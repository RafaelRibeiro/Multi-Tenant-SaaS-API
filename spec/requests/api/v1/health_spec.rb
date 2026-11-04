require "rails_helper"

RSpec.describe "Health API", type: :request do
  describe "GET /health" do
    it "returns the application health status" do
      get "/health"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["status"]).to eq("ok")
      expect(json["application"]).to eq("Multi-Tenant SaaS API")
      expect(json["database"]).to eq("connected")
      expect(json["timestamp"]).to be_present
    end
  end
end