class OrganizationPolicy < ApplicationPolicy
  def show?
    membership.present?
  end

  def update?
    !!(membership&.owner? || membership&.admin?)
  end

  def destroy?
    membership&.owner?
  end

  private

  def membership
    @membership ||= user.memberships.find_by(
      organization_id: record.id
    )
  end
end