require "rails_helper"

RSpec.describe OrganizationContext do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  describe "#resolve!" do
    context "when the user belongs to the organization" do
      let!(:membership) do
        create(:membership, user: user, organization: organization, role: :owner)
      end

      it "returns the organization" do
        context = described_class.new(
          user: user,
          organization_id: organization.id
        )

        expect(context.resolve!).to eq(organization)
      end

      it "sets the current context" do
        described_class.new(
          user: user,
          organization_id: organization.id
        ).resolve!

        expect(Current.user).to eq(user)
        expect(Current.organization).to eq(organization)
        expect(Current.membership).to eq(membership)
      end
    end

    context "when the user does not belong to the organization" do
      it "raises AccessDenied" do
        context = described_class.new(
          user: user,
          organization_id: organization.id
        )

        expect { context.resolve! }
          .to raise_error(OrganizationContext::AccessDenied)
      end
    end

    context "when the organization is inactive" do
      before do
        create(:membership, user: user, organization: organization)
        organization.update!(status: :inactive)
      end

      it "raises AccessDenied" do
        context = described_class.new(
          user: user,
          organization_id: organization.id
        )

        expect { context.resolve! }
          .to raise_error(OrganizationContext::AccessDenied)
      end
    end

    context "when the organization is suspended" do
      before do
        create(:membership, user: user, organization: organization)
        organization.update!(status: :suspended)
      end

      it "raises AccessDenied" do
        context = described_class.new(
          user: user,
          organization_id: organization.id
        )

        expect { context.resolve! }
          .to raise_error(OrganizationContext::AccessDenied)
      end
    end

    context "when access is denied with a previous context" do
      it "clears the previous organization context" do
        previous_organization = create(:organization)

        previous_membership = create(
          :membership,
          user: user,
          organization: previous_organization
        )

        Current.user = user
        Current.organization = previous_organization
        Current.membership = previous_membership

        context = described_class.new(
          user: user,
          organization_id: organization.id
        )

        expect { context.resolve! }
          .to raise_error(OrganizationContext::AccessDenied)

        expect(Current.user).to eq(user)
        expect(Current.organization).to be_nil
        expect(Current.membership).to be_nil
      end
    end
  end
end