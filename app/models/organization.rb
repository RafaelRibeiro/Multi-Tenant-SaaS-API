class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :clients, dependent: :destroy
  has_many :projects, dependent: :destroy

  enum :status, {
    active: 0,
    inactive: 1,
    suspended: 2
  }

  before_validation :normalize_slug

  validates :name, presence: true
  validates :slug, presence: true,
                    uniqueness: true,
                    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
  validates :status, presence: true

  private

  def normalize_slug
    self.slug = slug.to_s.parameterize
  end
end