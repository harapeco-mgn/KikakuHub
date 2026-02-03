module Availability
  module TimeConverter
    # "HH:MM" -> minutes (Integer) or nil
    def self.time_to_minutes(value)
      return nil if value.blank?
      return value if value.is_a?(Integer)

      m = value.to_s.match(/(\d{1,2}):(\d{2})/)
      return nil unless m

      m[1].to_i * 60 + m[2].to_i
    end
  end
end
