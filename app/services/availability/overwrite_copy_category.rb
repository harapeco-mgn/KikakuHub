module Availability
  class OverwriteCopyCategory
    def self.call(user:, from_category:, to_category:)
      new(user:, from_category:, to_category:).call
    end

    def initialize(user:, from_category:, to_category:)
      @user = user
      @from_category = from_category
      @to_category = to_category
    end

    def call
      now = Time.current

      rows = @user.availability_slots
                  .where(category: @from_category)
                  .pluck(:wday, :start_minute, :end_minute)
                  .uniq
                  .map do |wday, s, e|
                    {
                      user_id: @user.id,
                      category: @to_category,
                      wday: wday,
                      start_minute: s,
                      end_minute: e,
                      created_at: now,
                      updated_at: now
                    }
                  end

      deleted = 0

      ActiveRecord::Base.transaction do
        deleted = @user.availability_slots.where(category: @to_category).delete_all
        AvailabilitySlot.insert_all(rows) if rows.any?
      end

      { deleted: deleted, created: rows.size }
    end
  end
end
