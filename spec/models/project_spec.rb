require "rails_helper"

RSpec.describe Project, type: :model do
  describe "associations" do
    it { should belong_to(:organization) }
    it { should belong_to(:client).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:status) }
  end

  describe "client organization validation" do
    it "allows a client from the same organization" do
      organization = create(:organization)
      client = create(:client, organization: organization)

      project = build(
        :project,
        organization: organization,
        client: client
      )

      expect(project).to be_valid
    end

    it "does not allow a client from another organization" do
      organization = create(:organization)
      another_organization = create(:organization)

      client = create(:client, organization: another_organization)

      project = build(
        :project,
        organization: organization,
        client: client
      )

      expect(project).not_to be_valid
      expect(project.errors[:client]).to include(
        "must belong to the same organization"
      )
    end

    it "allows a project without a client" do
      project = build(:project, client: nil)

      expect(project).to be_valid
    end
  end
end