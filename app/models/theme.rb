class Theme < ApplicationRecord
  CATEGORY_KEYS = %w[tech community].freeze

  belongs_to :community
  belongs_to :user

  enum :category, { tech: 0, community: 1 }
  enum :status, { active: 0, archived: 1 }

  validates :category, presence: true
  validates :status, presence: true
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :secondary_label, presence: true, if: :secondary_enabled?

  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category) { where(category: category) }
  scope :popular, -> { order(theme_votes_count: :desc) }
  scope :active_themes, -> { where(status: :active) }
  scope :archived_themes, -> { where(status: :archived) }
  scope :search_by_keyword, ->(keyword) {
    return all if keyword.blank?
    where("title ILIKE :q OR description ILIKE :q", q: "%#{sanitize_sql_like(keyword)}%")
  }

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
