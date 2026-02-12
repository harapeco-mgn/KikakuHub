# frozen_string_literal: true

module Themes
  # 開催しやすさスコアを算出するサービスクラス
  # 投票数、参加表明率、参加可能時間の3つの要素から0-100のスコアを算出
  class HostingEaseCalculator
    # スコア計算の重み付け（合計1.0）
    WEIGHT_VOTES = 0.3        # 投票の重み
    WEIGHT_RSVP = 0.3         # 参加表明の重み
    WEIGHT_AVAILABILITY = 0.4 # 参加可能時間の重み

    # 正規化の上限値
    MAX_VOTES = 20            # 投票数の上限（これ以上は1.0として扱う）
    MAX_RSVP_RATE = 1.0       # 参加表明率の上限（100%）
    MAX_AVAILABILITY = 10     # 参加可能人数の上限（これ以上は1.0として扱う）

    def self.call(theme)
      new(theme).calculate
    end

    def initialize(theme)
      @theme = theme
    end

    def calculate
      {
        score: total_score,
        breakdown: {
          votes: votes_component,
          rsvp: rsvp_component,
          availability: availability_component
        },
        raw_data: {
          votes_count: votes_count,
          rsvp_rate: rsvp_rate,
          availability_count: availability_count
        }
      }
    end

    private

    def total_score
      (normalized_votes * WEIGHT_VOTES * 100 +
       normalized_rsvp * WEIGHT_RSVP * 100 +
       normalized_availability * WEIGHT_AVAILABILITY * 100).round
    end

    def votes_component
      (normalized_votes * WEIGHT_VOTES * 100).round(1)
    end

    def rsvp_component
      (normalized_rsvp * WEIGHT_RSVP * 100).round(1)
    end

    def availability_component
      (normalized_availability * WEIGHT_AVAILABILITY * 100).round(1)
    end

    # 投票数を0-1に正規化
    def normalized_votes
      return 0 if votes_count.zero?

      [votes_count.to_f / MAX_VOTES, 1.0].min
    end

    # 参加表明率を0-1に正規化
    def normalized_rsvp
      return 0 if total_rsvps.zero?

      [rsvp_rate, MAX_RSVP_RATE].min
    end

    # 参加可能人数を0-1に正規化
    def normalized_availability
      return 0 if availability_count.zero?

      [availability_count.to_f / MAX_AVAILABILITY, 1.0].min
    end

    def votes_count
      @votes_count ||= @theme.theme_votes_count || 0
    end

    def rsvp_rate
      @rsvp_rate ||= begin
        attending = @theme.rsvps.attending.count
        total = total_rsvps
        total.zero? ? 0 : attending.to_f / total
      end
    end

    def total_rsvps
      @total_rsvps ||= @theme.rsvps.count
    end

    def availability_count
      @availability_count ||= begin
        return 0 unless @theme.category.in?(Theme::CATEGORY_KEYS)

        counts = Availability::AggregateCounts.call(
          cohort: "all",
          category: @theme.category
        )
        suggested = Availability::SuggestSlots.call(counts)

        # 最も参加人数が多い候補日の平均参加人数を使用
        suggested.first&.dig(:avg_count) || 0
      end
    end
  end
end
