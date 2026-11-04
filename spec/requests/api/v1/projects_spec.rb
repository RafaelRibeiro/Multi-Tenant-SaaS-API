
require "rails_helper"

RSpec.describe "Projects API", type: :request do
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
    {
      "Authorization" => "Bearer #{token}",
      "X-Organization-ID" => organization.id.to_s
    }
  end

  describe "GET /api/v1/projects" do
    let!(:project) do
      create(:project, organization: organization)
    end

    it "returns the organization's projects" do
      get "/api/v1/projects", headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["projects"].length).to eq(1)
      expect(response.parsed_body["projects"].first["id"]).to eq(project.id)
    end

    it "does not return projects from another organization" do
      another_organization = create(:organization)
      create(:project, organization: another_organization)

      get "/api/v1/projects", headers: headers

      returned_ids = response.parsed_body["projects"].map { |p| p["id"] }

      expect(returned_ids).to contain_exactly(project.id)
    end

    it "returns 401 without authentication" do
      get "/api/v1/projects",
          headers: { "X-Organization-ID" => organization.id.to_s }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 when the user does not belong to the organization" do
      another_organization = create(:organization)

      get "/api/v1/projects",
          headers: {
            "Authorization" => "Bearer #{token}",
            "X-Organization-ID" => another_organization.id.to_s
          }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/projects" do
    let(:client) { create(:client, organization: organization) }

    let(:valid_params) do
      {
        name: "Novo Projeto",
        description: "Projeto criado pela API",
        status: "planning",
        start_date: Date.current,
        end_date: 30.days.from_now.to_date,
        client_id: client.id
      }
    end

    it "creates a project in the selected organization" do
      post "/api/v1/projects",
           params: { project: valid_params },
           headers: headers

      expect(response).to have_http_status(:created)
    end

    it "does not allow assigning a client from another organization" do
      other_organization = create(:organization)
      other_client = create(:client, organization: other_organization)

      expect {
        post "/api/v1/projects",
             params: {
               project: valid_params.merge(client_id: other_client.id)
             },
             headers: headers
      }.not_to change(Project, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "ignores organization_id sent in the request" do
      other_organization = create(:organization)

      post "/api/v1/projects",
           params: {
             project: valid_params.merge(
               organization_id: other_organization.id
             )
           },
           headers: headers

      expect(response).to have_http_status(:created)
      expect(Project.last.organization_id).to eq(organization.id)
    end

    it "creates a project without a client" do
      post "/api/v1/projects",
           params: {
             project: valid_params.except(:client_id)
           },
           headers: headers

      expect(response).to have_http_status(:created)
      expect(Project.last.client_id).to be_nil
    end

    it "returns 401 without authentication" do
      post "/api/v1/projects",
           params: { project: valid_params },
           headers: { "X-Organization-ID" => organization.id.to_s }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/projects/:id" do
    let!(:project) do
      create(:project, organization: organization)
    end

    it "returns the requested project" do
      get "/api/v1/projects/#{project.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["id"]).to eq(project.id)
      expect(response.parsed_body["name"]).to eq(project.name)
    end

    it "does not return a project from another organization" do
      other_organization = create(:organization)
      other_project = create(:project, organization: other_organization)

      get "/api/v1/projects/#{other_project.id}", headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("Project not found")
    end

    it "returns 401 without authentication" do
      get "/api/v1/projects/#{project.id}",
          headers: { "X-Organization-ID" => organization.id.to_s }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 404 when the project does not exist" do
      get "/api/v1/projects/999999", headers: headers

      expect(response).to have_http_status(:not_found)
    end

  end

  describe "PATCH /api/v1/projects/:id" do
    let!(:project) do
      create(:project, organization: organization)
    end

    it "updates the project" do
      patch "/api/v1/projects/#{project.id}",
            params: {
              project: {
                name: "Projeto Atualizado",
                description: "Nova descriÃ§Ã£o"
              }
            },
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["name"]).to eq("Projeto Atualizado")
      expect(project.reload.name).to eq("Projeto Atualizado")
    end

    it "does not update a project from another organization" do
      other_organization = create(:organization)
      other_project = create(:project, organization: other_organization)

      patch "/api/v1/projects/#{other_project.id}",
            params: {
              project: { name: "Tentativa de alteraÃ§Ã£o" }
            },
            headers: headers

      expect(response).to have_http_status(:not_found)
      expect(other_project.reload.name).not_to eq("Tentativa de alteraÃ§Ã£o")
    end

    it "does not allow changing the organization_id" do
      other_organization = create(:organization)

      patch "/api/v1/projects/#{project.id}",
            params: {
              project: {
                name: "Projeto Atualizado",
                organization_id: other_organization.id
              }
            },
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(project.reload.organization_id).to eq(organization.id)
    end

    it "returns 422 when the project name is blank" do
      patch "/api/v1/projects/#{project.id}",
            params: {
              project: { name: "" }
            },
            headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(project.reload.name).to eq("Projeto de Teste")
    end

    it "returns 401 without authentication" do
      patch "/api/v1/projects/#{project.id}",
            params: {
              project: { name: "Projeto Atualizado" }
            },
            headers: {
              "X-Organization-ID" => organization.id.to_s
            }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 404 when the project does not exist" do
      get "/api/v1/projects/999999", headers: headers

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("Project not found")
    end
  end

  describe "DELETE /api/v1/projects/:id" do
    let!(:project) do
      create(:project, organization: organization)
    end

    it "deletes the project" do
      expect {
        delete "/api/v1/projects/#{project.id}", headers: headers
      }.to change(Project, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["message"]).to eq(
        "Project deleted successfully"
      )
    end

    it "does not delete a project from another organization" do
      other_organization = create(:organization)
      other_project = create(:project, organization: other_organization)

      expect {
        delete "/api/v1/projects/#{other_project.id}", headers: headers
      }.not_to change(Project, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when the project does not exist" do
      delete "/api/v1/projects/999999", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 401 without authentication" do
      delete "/api/v1/projects/#{project.id}",
             headers: {
               "X-Organization-ID" => organization.id.to_s
             }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
