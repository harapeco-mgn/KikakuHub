module Admin
  class DashboardsController < BaseController
    def show
      # 既存: 週別推移グラフ
      @weekly_themes = Theme.group_by_week(:created_at, last: 12).count
      @weekly_rsvps  = Rsvp.group_by_week(:created_at, last: 12).count

      # 開催成功率
      confirmed_or_done = Theme.where(status: %i[confirmed done]).count
      done_count        = Theme.where(status: :done).count
      @success_rate = confirmed_or_done.positive? ? (done_count.to_f / confirmed_or_done * 100).round(1) : 0.0
      @theme_status_counts = Theme.group(:status).count

      # カテゴリ別傾向
      @votes_by_category   = ThemeVote.joins(:theme).group("themes.category").count
      @rsvps_by_category   = Rsvp.where(status: :attending).joins(:theme).group("themes.category").count

      # 開催しやすさスコア分布（キャッシュ済みスコアをバケット化）
      @hosting_ease_distribution = Theme.where.not(hosting_ease_score_cache: nil)
                                        .group(
                                          Arel.sql(
                                            "CASE
                                              WHEN hosting_ease_score_cache >= 80 THEN '高（80〜）'
                                              WHEN hosting_ease_score_cache >= 50 THEN '中（50〜79）'
                                              ELSE '低（〜49）'
                                            END"
                                          )
                                        ).count
    end
  end
end
