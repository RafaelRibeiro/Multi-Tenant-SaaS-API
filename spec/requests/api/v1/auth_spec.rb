require "rails_helper"

RSpec.describe "Authentication API", type: :request do
  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user) }

    context "with valid credentials" do
      it "returns a JWT token" do
        post "/api/v1/auth/login", params: {
          email: user.email,
          password: "password123"
        }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)

        expect(json["token"]).to be_present
        expect(json["token_type"]).to eq("Bearer")
        expect(json["expires_in"]).to eq(24.hours.to_i)

        decoded_token = JsonWebToken.decode(json["token"])

        expect(decoded_token["sub"]).to eq(user.id)
      end
    end

    context "with invalid credentials" do
      it "rejects an incorrect password" do
        post "/api/v1/auth/login", params: {
          email: user.email,
          password: "wrongpassword"
        }

        expect(response).to have_http_status(:unauthorized)
      end

      it "rejects a nonexistent user" do
        post "/api/v1/auth/login", params: {
          email: "unknown@example.com",
          password: "password123"
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end