module AvailabilityHelper
  def minutes_to_hhmm(min)
    h = min / 60
    m = min % 60
    format("%02d:%02d", h, m)
  end

  def range_to_label(range)
    "#{minutes_to_hhmm(range[:start_minute])}〜#{minutes_to_hhmm(range[:end_minute])}"
  end
end