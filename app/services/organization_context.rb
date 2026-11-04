class OrganizationContext
  class AccessDenied < StandardError; end

  def initialize(user:, organization_id:)
    @user = user
    @organization_id = organization_id
  end

  def resolve!
    Current.user = @user
    Current.organization = nil
    Current.membership = nil

    membership = @user.memberships
                      .includes(:organization)
                      .find_by(organization_id: @organization_id)

    raise AccessDenied, "Access to this organization is denied" unless membership

    organization = membership.organization

    raise AccessDenied, "This organization is not active" unless organization.active?

    Current.organization = organization
    Current.membership = membership

    organization
  end
end