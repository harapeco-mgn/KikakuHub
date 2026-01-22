require "set"

module Availability
  class AggregateCounts
    SLOTS_PER_DAY = 48
    WDAYS = 0..6

    # cohort: "all" または 数値（StringでもOK）
    # category: "tech" / "community"
    def self.call(cohort:, category:)
      cohort_value = normalize_cohort(cohort)
      category_value = category.to_s

      # 0件でも安定するように 7×48 の Set 配列を先に作る
      seen = empty_seen_matrix

      relation = AvailabilitySlot.where(category: category_value)

      # cohort が all 以外なら users.cohort で絞る
      if cohort_value
        relation = relation.joins(:user).where(users: { cohort: cohort_value })
      end

      # 必要最小限のカラムだけ読む
      relation.select(:id, :user_id, :wday, :start_minute, :end_minute).find_each do |slot|
        wday = slot.wday
        next unless WDAYS.cover?(wday)

        start_idx = (slot.start_minute.to_i / 30).clamp(0, SLOTS_PER_DAY)
        end_idx   = (slot.end_minute.to_i / 30).clamp(0, SLOTS_PER_DAY)

        # end は「ちょうど端」なので含めない（start...end）
        (start_idx...end_idx).each do |i|
          seen[wday][i].add(slot.user_id)
        end
      end

      # Set のサイズに変換して counts を作る
      seen.map { |row| row.map(&:size) }
    end

    def self.normalize_cohort(cohort)
      s = cohort.to_s
      return nil if s.blank? || s == "all"
      s.to_i
    end

    def self.empty_seen_matrix
      Array.new(7) { Array.new(SLOTS_PER_DAY) { Set.new } }
    end

    private_class_method :normalize_cohort, :empty_seen_matrix
  end
end