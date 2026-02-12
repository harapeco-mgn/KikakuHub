module Availability
  class SuggestSlots
    SLOTS_PER_DAY = 48
    MIN_DURATION_SLOTS = 2 # 1時間（30分×2）以上
    TOP_N = 3

    # counts: 7×48 の2次元配列（AggregateCounts.call の戻り値）
    # min_participants: 最低参加人数（これ未満のスロットは候補外）
    def self.call(counts, min_participants: 1)
      return [] if counts.blank?

      candidates = []

      counts.each_with_index do |day_counts, wday|
        blocks = find_contiguous_blocks(day_counts, wday, min_participants)
        candidates.concat(blocks)
      end

      candidates
        .select { |b| b[:slots] >= MIN_DURATION_SLOTS }
        .sort_by { |b| [ -b[:min_count], -b[:slots] ] }
        .first(TOP_N)
    end

    def self.find_contiguous_blocks(day_counts, wday, min_participants)
      blocks = []
      current_start = nil
      current_min = nil

      day_counts.each_with_index do |count, slot|
        if count >= min_participants
          if current_start.nil?
            current_start = slot
            current_min = count
          else
            current_min = [ current_min, count ].min
          end
        else
          if current_start
            blocks << build_block(wday, current_start, slot, current_min)
            current_start = nil
            current_min = nil
          end
        end
      end

      if current_start
        blocks << build_block(wday, current_start, SLOTS_PER_DAY, current_min)
      end

      blocks
    end

    def self.build_block(wday, start_slot, end_slot, min_count)
      {
        wday: wday,
        start_minute: start_slot * 30,
        end_minute: end_slot * 30,
        min_count: min_count,
        slots: end_slot - start_slot
      }
    end

    private_class_method :find_contiguous_blocks, :build_block
  end
end
