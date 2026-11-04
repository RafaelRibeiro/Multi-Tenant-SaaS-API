require "rails_helper"

RSpec.describe "Clients API", type: :request do
  let!(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(sub: user.id) }
  let!(:organization) { create(:organization) }
  let!(:membership) do
    create(:membership, user: user, organization: organization, role: :owner)
  end

  let(:headers) do
    {
      "Authorization" => "Bearer #{token}",
      "X-Organization-ID" => organization.id.to_s
    }
  end

  describe "GET /api/v1/clients" do
    context "when the user belongs to the organization" do
      let!(:client) { create(:client, organization: organization) }

      it "returns the organization's clients" do
        get "/api/v1/clients", headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["clients"].length).to eq(1)
        expect(response.parsed_body["clients"].first["id"]).to eq(client.id)
      end

      it "does not return clients from another organization" do
        another_organization = create(:organization)
        create(:client, organization: another_organization)

        get "/api/v1/clients", headers: headers

        returned_ids = response.parsed_body["clients"].map { |c| c["id"] }

        expect(returned_ids).to contain_exactly(client.id)
      end
    end

    it "returns 401 without authentication" do
      get "/api/v1/clients",
          headers: { "X-Organization-ID" => organization.id.to_s }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 when the user does not belong to the organization" do
      another_organization = create(:organization)

      get "/api/v1/clients",
          headers: {
            "Authorization" => "Bearer #{token}",
            "X-Organization-ID" => another_organization.id.to_s
          }

      expect(response).to have_http_status(:forbidden)
    end

    describe "POST /api/v1/clients" do
      let(:valid_params) do
        {
          client: {
            name: "Cliente Teste",
            email: "cliente@example.com",
            phone: "11999999999",
            status: "active"
          }
        }
      end

      it "creates a client in the selected organization" do
        expect {
          post "/api/v1/clients",
               params: valid_params,
               headers: headers
        }.to change(Client, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body["name"]).to eq("Cliente Teste")
        expect(Client.last.organization_id).to eq(organization.id)
      end

      it "does not allow assigning a client to another organization" do
        another_organization = create(:organization)

        params = valid_params.deep_merge(
          client: { organization_id: another_organization.id }
        )

        post "/api/v1/clients", params: params, headers: headers

        expect(response).to have_http_status(:created)
        expect(Client.last.organization_id).to eq(organization.id)
      end

      it "returns 422 when name is missing" do
        params = { client: { email: "cliente@example.com" } }

        post "/api/v1/clients", params: params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 401 without authentication" do
        post "/api/v1/clients",
             params: valid_params,
             headers: { "X-Organization-ID" => organization.id.to_s }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/clients/:id" do
    let!(:client) { create(:client, organization: organization) }

    it "returns the requested client" do
      get "/api/v1/clients/#{client.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["id"]).to eq(client.id)
      expect(response.parsed_body["name"]).to eq(client.name)
    end

    it "returns 404 when the client belongs to another organization" do
      another_organization = create(:organization)
      another_client = create(:client, organization: another_organization)

      get "/api/v1/clients/#{another_client.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when the client does not exist" do
      get "/api/v1/clients/999999", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 401 without authentication" do
      get "/api/v1/clients/#{client.id}"

      expect(response).to have_http_status(:unauthorized)
    end
  end
  describe "PATCH /api/v1/clients/:id" do
    let!(:client) { create(:client, organization: organization) }

    it "updates the client" do
      patch "/api/v1/clients/#{client.id}",
            params: { client: { name: "Cliente Atualizado" } },
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["name"]).to eq("Cliente Atualizado")
      expect(client.reload.name).to eq("Cliente Atualizado")
    end

    it "does not update a client from another organization" do
      another_organization = create(:organization)
      another_client = create(:client, organization: another_organization)

      patch "/api/v1/clients/#{another_client.id}",
            params: { client: { name: "Tentativa de invasÃ£o" } },
            headers: headers

      expect(response).to have_http_status(:not_found)
      expect(another_client.reload.name).not_to eq("Tentativa de invasÃ£o")
    end

    it "returns 404 when the client does not exist" do
      patch "/api/v1/clients/999999",
            params: { client: { name: "Cliente Atualizado" } },
            headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 when the update is invalid" do
      patch "/api/v1/clients/#{client.id}",
            params: { client: { name: "" } },
            headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /api/v1/clients/:id" do
    let!(:client) { create(:client, organization: organization) }

    it "deletes the client" do
      expect {
        delete "/api/v1/clients/#{client.id}", headers: headers
      }.to change(Client, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "does not delete a client from another organization" do
      another_organization = create(:organization)
      another_client = create(:client, organization: another_organization)

      expect {
        delete "/api/v1/clients/#{another_client.id}", headers: headers
      }.not_to change(Client, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when the client does not exist" do
      delete "/api/v1/clients/999999", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 401 without authentication" do
      delete "/api/v1/clients/#{client.id}"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end