module Availability
  class SuggestSlots
    SLOTS_PER_DAY = 48
    MIN_DURATION_SLOTS = 2 # 1時間（30分×2）以上
    MAX_DURATION_SLOTS = 8 # 4時間（30分×8）以下
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
        .sort_by { |b| [ -b[:avg_count], -b[:min_count], -b[:slots] ] }
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
            blocks.concat(process_block(wday, current_start, slot, current_min, day_counts))
            current_start = nil
            current_min = nil
          end
        end
      end

      if current_start
        blocks.concat(process_block(wday, current_start, SLOTS_PER_DAY, current_min, day_counts))
      end

      blocks
    end

    def self.process_block(wday, start_slot, end_slot, min_count, day_counts)
      slots = end_slot - start_slot

      # MAX_DURATION_SLOTS以下ならそのまま返す
      if slots <= MAX_DURATION_SLOTS
        avg_count = calculate_avg_count(day_counts, start_slot, end_slot)
        return [ build_block(wday, start_slot, end_slot, min_count, avg_count) ]
      end

      # MAX_DURATION_SLOTSを超える場合、スライディングウィンドウで最適なサブウィンドウを抽出
      best_window = find_best_window(wday, start_slot, end_slot, day_counts)
      best_window ? [ best_window ] : []
    end

    def self.find_best_window(wday, start_slot, end_slot, day_counts)
      best_avg = -1
      best_window = nil

      # スライディングウィンドウで最もavg_countが高い区間を探す
      (start_slot..end_slot - MAX_DURATION_SLOTS).each do |window_start|
        window_end = window_start + MAX_DURATION_SLOTS
        avg_count = calculate_avg_count(day_counts, window_start, window_end)
        min_count = day_counts[window_start...window_end].min

        if avg_count > best_avg
          best_avg = avg_count
          best_window = build_block(wday, window_start, window_end, min_count, avg_count)
        end
      end

      best_window
    end

    def self.calculate_avg_count(day_counts, start_slot, end_slot)
      slot_range = day_counts[start_slot...end_slot]
      return 0.0 if slot_range.empty?

      slot_range.sum.to_f / slot_range.size
    end

    def self.build_block(wday, start_slot, end_slot, min_count, avg_count)
      {
        wday: wday,
        start_minute: start_slot * 30,
        end_minute: end_slot * 30,
        min_count: min_count,
        avg_count: avg_count,
        slots: end_slot - start_slot
      }
    end

    private_class_method :find_contiguous_blocks, :process_block, :find_best_window, :calculate_avg_count, :build_block
  end
end
