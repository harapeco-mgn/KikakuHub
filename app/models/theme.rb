class Theme < ApplicationRecord
  belongs_to :community
  belongs_to :user

  enum :category, { tech: 0, community: 1 }

  validates :category, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :body, presence: true, length: { maximum: 255 }

  has_many :theme_votes, dependent: :destroy
  has_many :voters, through: :theme_votes, source: :user
  has_many :theme_comments, dependent: :destroy
  has_many :rsvps, dependent: :destroy
  has_many :rsvp_users, through: :rsvps, source: :user

  def rsvp_counts
    grouped = rsvps.group(:status).count.symbolize_keys
    {
    attending:     grouped.fetch(:attending, 0),
    not_attending: grouped.fetch(:not_attending, 0),
    undecided:     grouped.fetch(:undecided, 0)
    }
  end
end
