require "rails_helper"

RSpec.describe "Protected API", type: :request do
  let!(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(sub: user.id) }

  describe "GET /api/v1/protected" do
    it "allows access with a valid token" do
      get "/api/v1/protected", headers: {
        "Authorization" => "Bearer #{token}"
      }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["message"]).to eq("Authenticated successfully")
      expect(json["user_id"]).to eq(user.id)
    end

    it "rejects requests without a token" do
      get "/api/v1/protected"

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects invalid tokens" do
      get "/api/v1/protected", headers: {
        "Authorization" => "Bearer invalid.token"
      }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end