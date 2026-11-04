class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :client, optional: true

  validates :name, presence: true
  validates :status, presence: true

  validate :client_belongs_to_organization

  private

  def client_belongs_to_organization
    return unless client && organization

    if client.organization_id != organization_id
      errors.add(:client, "must belong to the same organization")
    end
  end
end