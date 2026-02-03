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
      slots_hash = normalize_slots_hash(@slots_param)

      ActiveRecord::Base.transaction do
        slots_hash.each do |key, attrs|
          attrs = attrs.to_unsafe_h if attrs.is_a?(ActionController::Parameters)
          p = ActionController::Parameters.new(attrs).permit(:start_time, :end_time, :wday, :category)

          start_minute = Availability::TimeConverter.time_to_minutes(p[:start_time])
          end_minute   = Availability::TimeConverter.time_to_minutes(p[:end_time])

          if key.to_s.start_with?("new_")
            next if start_minute.nil? || end_minute.nil?
            next if start_minute >= end_minute

            @user.availability_slots.create!(
              wday: p[:wday].to_i,
              category: (p[:category].presence || @category),
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

    private

    def normalize_slots_hash(slots_param)
      h = slots_param || {}
      h = h.to_unsafe_h if h.is_a?(ActionController::Parameters)
      h
    end
  end
end
