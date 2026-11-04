class Client < ApplicationRecord
  belongs_to :organization
  has_many :projects, dependent: :nullify

  validates :name, presence: true
  validates :status, presence: true
end