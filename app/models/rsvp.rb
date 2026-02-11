class Rsvp < ApplicationRecord
  belongs_to :user
  belongs_to :theme

  enum status: { attending: 0, not_attending: 1, undecided: 2 }

  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :theme_id }

  before_validation :set_default_status, on: :create
  before_save :clear_secondary_interest_unless_attending

  private

  def set_default_status
    self.status ||= :undecided
  end

  def clear_secondary_interest_unless_attending
    self.secondary_interest = false unless attending?
  end
end
