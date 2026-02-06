class Community < ApplicationRecord
  DEFAULT_ID = 1

  has_many :themes, dependent: :restrict_with_error

  validates :name, presence: true
end
