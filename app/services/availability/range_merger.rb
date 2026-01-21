module Availability
  class RangeMerger
    # inputs: [{ start_minute:, end_minute:, ids: [id] }, ...]
    # output: merged ranges with ids
    def self.call(ranges)
      ranges = ranges
        .compact
        .map do |r|
          {
            start_minute: r[:start_minute],
            end_minute: r[:end_minute],
            ids: Array(r[:ids])
          }
        end
        .sort_by { |r| r[:start_minute] }

      merged = []

      ranges.each do |r|
        if merged.empty?
          merged << r
          next
        end

        last = merged[-1]

        # 重複 or 連続（next.start <= current.end）ならマージ
        if r[:start_minute] <= last[:end_minute]
          last[:end_minute] = [last[:end_minute], r[:end_minute]].max
          last[:ids] = (last[:ids] + r[:ids]).uniq
        else
          merged << r
        end
      end

      merged
    end
  end
end