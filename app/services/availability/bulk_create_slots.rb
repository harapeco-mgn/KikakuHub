module Availability
  class BulkCreateSlots
    def self.call(user:, category:, wdays:, start_minute:, end_minute:)
      new(user:, category:, wdays:, start_minute:, end_minute:).call
    end

    # "HH:MM" -> minutes
    def self.time_to_minutes(value)
      return nil if value.blank?
      return value if value.is_a?(Integer)

      m = value.to_s.match(/(\d{1,2}):(\d{2})/)
      return nil unless m

      m[1].to_i * 60 + m[2].to_i
    end

    def initialize(user:, category:, wdays:, start_minute:, end_minute:)
      @user = user
      @category = category
      @wdays = wdays
      @start_minute = start_minute
      @end_minute = end_minute
    end

    def call
      created = 0            # gap で「2本になる」追加が起きた日
      merged = 0             # overlap/adjacent/bridge で「統合（広がり）」が起きる日
      unchanged = 0          # 追加しても変化しない（完全に含まれる/完全一致）日
      unchanged_wdays = []

      existing = @user.availability_slots.where(category: @category, wday: @wdays)
      existing_by_wday = existing.group_by(&:wday)

      ActiveRecord::Base.transaction do
        @wdays.each do |wday|
          slots = existing_by_wday[wday] || []

          # 既存が完全に含んでいるなら、何も変わらないので作らない
          if covered_by_existing?(slots, @start_minute, @end_minute)
            unchanged += 1
            unchanged_wdays << wday
            next
          end

          # 既存と重なり/隣接していれば、追加後に正規化で統合される（= merged）
          if touches_any?(slots, @start_minute, @end_minute)
            merged += 1
          else
            created += 1
          end

          begin
            @user.availability_slots.create!(
              wday: wday,
              category: @category,
              start_minute: @start_minute,
              end_minute: @end_minute
            )
          rescue ActiveRecord::RecordNotUnique
            # 完全一致などで既に同じ枠がある場合
            # カウントを「変更なし」に寄せる
            created -= 1 if created.positive? && !touches_any?(slots, @start_minute, @end_minute)
            merged  -= 1 if merged.positive?  &&  touches_any?(slots, @start_minute, @end_minute)
            unchanged += 1
            unchanged_wdays << wday
          end
        end

        # 追加/統合が起きたときだけ正規化
        Availability::WeeklySlotNormalizer.call(user: @user, category: @category) if (created + merged).positive?
      end

      { created: created, merged: merged, unchanged: unchanged, unchanged_wdays: unchanged_wdays.uniq.sort }
    end

    private

    # 既存が new を完全に含む（追加しても見た目が変わらない）
    def covered_by_existing?(slots, new_s, new_e)
      slots.any? do |slot|
        s = slot.start_minute
        e = slot.end_minute
        next false if s.nil? || e.nil?
        s <= new_s && e >= new_e
      end
    end

    # overlap または adjacent（正規化でつながる可能性がある）
    # new_s == e のような隣接も true にする（広げたいから）
    def touches_any?(slots, new_s, new_e)
      slots.any? do |slot|
        s = slot.start_minute
        e = slot.end_minute
        next false if s.nil? || e.nil?
        new_s <= e && new_e >= s
      end
    end
  end
end
