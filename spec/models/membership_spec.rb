require "rails_helper"

RSpec.describe Membership, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:organization) }
  end

  describe "validations" do
    it { should validate_presence_of(:role) }
  end

  describe "enums" do
    it "defines the correct roles" do
      expect(described_class.roles).to eq(
        "owner" => 0,
        "admin" => 1,
        "member" => 2
      )
    end
  end

  describe "uniqueness" do
    it "does not allow the same user in an organization twice" do
      membership = create(:membership)

      duplicate = build(
        :membership,
        user: membership.user,
        organization: membership.organization
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end

    it "allows the same user in different organizations" do
      user = create(:user)

      create(:membership, user: user)
      another_membership = build(:membership, user: user)

      expect(another_membership).to be_valid
    end
  end
end