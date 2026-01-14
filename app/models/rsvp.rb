class Rsvp < ApplicationRecord
  belongs_to :user
  belongs_to :theme

  enum status: { attending: 0, not_attending: 1, undecided: 2 }

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :theme_id }
end
