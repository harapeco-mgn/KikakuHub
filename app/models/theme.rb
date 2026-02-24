class Theme < ApplicationRecord
  include Hideable
  include Reportable

  CATEGORY_KEYS = %w[tech community].freeze

  belongs_to :community
  belongs_to :user

  enum :category, { tech: 0, community: 1 }
  enum :status, { considering: 0, archived: 1, confirmed: 2, done: 3 }

  validates :category, presence: true
  validates :status, presence: true
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :secondary_label, presence: true, if: :secondary_enabled?
  validates :converted_event_url,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                      message: "は有効なURLを入力してください" },
            allow_blank: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category) { where(category: category) }
  scope :popular, -> { order(theme_votes_count: :desc) }
  scope :by_hosting_ease, -> { order(hosting_ease_score_cache: :desc) }
  scope :active_themes, -> { visible.where.not(status: :archived) }
  scope :archived_themes, -> { visible.where(status: :archived) }
  scope :search_by_keyword, ->(keyword) {
    return all if keyword.blank?
    where("title ILIKE :q OR description ILIKE :q", q: "%#{sanitize_sql_like(keyword)}%")
  }

  has_many :theme_votes, dependent: :destroy
  has_many :voters, through: :theme_votes, source: :user
  has_many :theme_comments, dependent: :destroy
  has_many :rsvps, dependent: :destroy
  has_many :rsvp_users, through: :rsvps, source: :user

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def expiring_soon?
    expires_at.present? && !expired? && expires_at < 3.days.from_now
  end

  def rsvp_counts
    grouped = rsvps.group(:status).count.symbolize_keys
    {
    attending:     grouped.fetch(:attending, 0),
    not_attending: grouped.fetch(:not_attending, 0),
    undecided:     grouped.fetch(:undecided, 0)
    }
  end

  def hosting_ease_score
    Themes::HostingEaseCalculator.call(self)
  end

  def recalculate_hosting_ease_score!
    score = Themes::HostingEaseCalculator.call(self)[:score]
    update_column(:hosting_ease_score_cache, score)
  end
end
