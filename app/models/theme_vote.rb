class ThemeVote < ApplicationRecord
  belongs_to :user
  belongs_to :theme, counter_cache: true

  validates :user_id, uniqueness: { scope: :theme_id }

  after_commit :recalculate_theme_hosting_ease

  private

  def recalculate_theme_hosting_ease
    theme.recalculate_hosting_ease_score!
  end
end
