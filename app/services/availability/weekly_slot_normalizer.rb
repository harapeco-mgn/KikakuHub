module Availability
  class WeeklySlotNormalizer
    # 重なり/連続をまとめて、DB上も1本にする
    # category は "tech"/"community" を想定（enumでもOK）
    def self.call(user:, category:)
      slots = user.availability_slots
                  .where(category: category)
                  .where.not(start_minute: nil, end_minute: nil)
                  .order(:wday, :start_minute, :end_minute)

      slots.group_by(&:wday).each_value do |day_slots|
        merge_day!(day_slots)
      end
    end

    def self.merge_day!(day_slots)
      sorted = day_slots.sort_by(&:start_minute)

      merged = []
      sorted.each do |slot|
        if merged.empty?
          merged << { keep: slot, start: slot.start_minute, end: slot.end_minute, remove: [] }
          next
        end

        last = merged[-1]

        # overlap or adjacent (連続もまとめる)
        if slot.start_minute <= last[:end]
          last[:end] = [ last[:end], slot.end_minute ].max
          last[:remove] << slot
        else
          merged << { keep: slot, start: slot.start_minute, end: slot.end_minute, remove: [] }
        end
      end

      merged.each do |m|
        keep = m[:keep]

        # まとめた値を代表レコードに反映（start_minute/end_minute を直接更新）
        if keep.start_minute != m[:start] || keep.end_minute != m[:end]
          keep.update!(start_minute: m[:start], end_minute: m[:end])
        end

        # 代表以外は削除
        m[:remove].each(&:destroy!)
      end
    end
    private_class_method :merge_day!
  end
end
