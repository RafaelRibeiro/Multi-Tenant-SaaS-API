require "rails_helper"

RSpec.describe OrganizationPolicy do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }

  subject(:policy) do
    described_class.new(user, organization)
  end

  describe "#show?" do
    context "when user belongs to the organization" do
      before do
        create(:membership, user: user, organization: organization)
      end

      it "allows access" do
        expect(policy.show?).to be true
      end
    end

    context "when user does not belong to the organization" do
      it "denies access" do
        expect(policy.show?).to be false
      end
    end
  end

  describe "#update?" do
    it "allows owners" do
      create(:membership, user: user, organization: organization, role: :owner)

      expect(policy.update?).to be true
    end

    it "allows admins" do
      create(:membership, user: user, organization: organization, role: :admin)

      expect(policy.update?).to be true
    end

    it "denies members" do
      create(:membership, user: user, organization: organization, role: :member)

      expect(policy.update?).to be false
    end

    it "denies users without membership" do
      expect(policy.update?).to be false
    end
  end

  describe "#destroy?" do
    it "allows owners" do
      create(:membership, user: user, organization: organization, role: :owner)

      expect(policy.destroy?).to be true
    end

    it "denies admins" do
      create(:membership, user: user, organization: organization, role: :admin)

      expect(policy.destroy?).to be false
    end

    it "denies members" do
      create(:membership, user: user, organization: organization, role: :member)

      expect(policy.destroy?).to be false
    end
  end
end