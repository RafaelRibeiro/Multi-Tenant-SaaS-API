class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, {
    owner: 0,
    admin: 1,
    member: 2
  }

  validates :role, presence: true
  validates :user_id, uniqueness: {
    scope: :organization_id
  }
end