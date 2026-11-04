require "rails_helper"

RSpec.describe "Organizations API", type: :request do
  let!(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(sub: user.id) }

  let!(:organization) { create(:organization) }

  let!(:membership) do
    create(
      :membership,
      user: user,
      organization: organization,
      role: :owner
    )
  end

  let(:headers) do
    { "Authorization" => "Bearer #{token}" }
  end

  describe "POST /api/v1/organizations/:organization_id/select" do
    it "allows a user to select an organization they belong to" do
      post "/api/v1/organizations/#{organization.id}/select",
           headers: headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["message"]).to eq("Organization selected successfully")
      expect(json["organization"]["id"]).to eq(organization.id)
      expect(json["role"]).to eq("owner")
    end

    it "rejects access to an organization without membership" do
      other_organization = create(:organization)

      post "/api/v1/organizations/#{other_organization.id}/select",
           headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it "rejects access to an inactive organization" do
      inactive_organization = create(
        :organization,
        status: :inactive
      )

      create(
        :membership,
        user: user,
        organization: inactive_organization
      )

      post "/api/v1/organizations/#{inactive_organization.id}/select",
           headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it "rejects requests without authentication" do
      post "/api/v1/organizations/#{organization.id}/select"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/organizations/:id" do
    it "allows a member to view their organization" do
      get "/api/v1/organizations/#{organization.id}",
          headers: headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["id"]).to eq(organization.id)
      expect(json["name"]).to eq(organization.name)
    end

    it "denies access to users without membership" do
      other_organization = create(:organization)

      get "/api/v1/organizations/#{other_organization.id}",
          headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it "returns not found for a nonexistent organization" do
      get "/api/v1/organizations/999999",
          headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "rejects requests without authentication" do
      get "/api/v1/organizations/#{organization.id}"

      expect(response).to have_http_status(:unauthorized)
    end
  end

end