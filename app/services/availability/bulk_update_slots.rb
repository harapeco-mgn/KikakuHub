module Availability
  class BulkUpdateSlots
    def self.call(user:, category:, slots_param:)
      new(user:, category:, slots_param:).call
    end

    def initialize(user:, category:, slots_param:)
      @user = user
      @category = category
      @slots_param = slots_param
    end

    def call
      slots_hash = @slots_param || {}

      ActiveRecord::Base.transaction do
        slots_hash.each do |key, attrs|
          start_minute = Availability::TimeConverter.time_to_minutes(attrs[:start_time] || attrs["start_time"])
          end_minute   = Availability::TimeConverter.time_to_minutes(attrs[:end_time] || attrs["end_time"])

          if key.to_s.start_with?("new_")
            next if start_minute.nil? || end_minute.nil?
            next if start_minute >= end_minute

            wday = (attrs[:wday] || attrs["wday"]).to_i
            category = (attrs[:category] || attrs["category"]).presence || @category

            @user.availability_slots.create!(
              wday: wday,
              category: category,
              start_minute: start_minute,
              end_minute: end_minute
            )
          else
            slot = @user.availability_slots.find(key)
            raise ActiveRecord::RecordInvalid.new(slot) if start_minute.nil? || end_minute.nil? || start_minute >= end_minute
            slot.update!(start_minute: start_minute, end_minute: end_minute)
          end
        end

        Availability::WeeklySlotNormalizer.call(user: @user, category: @category)
      end
    end
  end
end
