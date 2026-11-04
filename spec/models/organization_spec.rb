require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "associations" do
    it { should have_many(:memberships).dependent(:destroy) }
    it { should have_many(:users).through(:memberships) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_presence_of(:status) }

    it "validates the uniqueness of slug" do
      create(:organization, slug: "empresa-teste")

      organization = build(:organization, slug: "empresa-teste")

      expect(organization).not_to be_valid
      expect(organization.errors[:slug]).to include("has already been taken")
    end
  end

  describe "enums" do
    it "defines the correct statuses" do
      expect(described_class.statuses).to eq(
        "active" => 0,
        "inactive" => 1,
        "suspended" => 2
      )
    end
  end

  describe "callbacks" do
    it "normalizes the slug before validation" do
      organization = build(:organization, slug: "Minha Empresa")

      organization.valid?

      expect(organization.slug).to eq("minha-empresa")
    end
  end
end