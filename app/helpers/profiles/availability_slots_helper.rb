module Profiles
  module AvailabilitySlotsHelper
    def wday_options
      {
        en: %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday],
        jp: %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日],
        order: (0..6).to_a
      }
    end

    def time_options
      (0..47).map do |i|
        m = i * 30
        label = format("%02d:%02d", m / 60, m % 60)
        [label, label]
      end
    end

    def end_time_options
      time_options + [["24:00", "24:00"]]
    end

    def minute_to_hhmm(minutes)
      format("%02d:%02d", minutes / 60, minutes % 60)
    end

    def selected_time(obj, minute_attr, fallback_attr)
      if obj.respond_to?(minute_attr) && !obj.public_send(minute_attr).nil?
        minute_to_hhmm(obj.public_send(minute_attr))
      else
        obj.public_send(fallback_attr).to_s
      end
    end
  end
end
