module AvailabilityHelper
  WDAY_LABELS = %w[日 月 火 水 木 金 土].freeze

  def minutes_to_hhmm(min)
    h = min / 60
    m = min % 60
    format("%02d:%02d", h, m)
  end

  def range_to_label(range)
    "#{minutes_to_hhmm(range[:start_minute])}〜#{minutes_to_hhmm(range[:end_minute])}"
  end

  # 集計カレンダー用：人数に応じたセルのCSSクラスを決定
  # @param count [Integer] 参加可能人数
  # @return [String] TailwindCSSクラス
  def aggregate_cell_class_for_count(count)
    case count
    when 0 then "bg-base-100 text-base-content/20"
    when 1..2 then "bg-sky-100 text-sky-800"
    when 3..5 then "bg-sky-300 text-sky-900"
    when 6..8 then "bg-sky-500 text-white font-medium"
    else "bg-sky-700 text-white font-bold"
    end
  end

  # 集計カレンダー用：セルのツールチップテキストを生成
  # @param wday [Integer] 曜日インデックス（0=日曜）
  # @param time_label [String] 時間ラベル（例: "09:00"）
  # @param count [Integer] 参加可能人数
  # @return [String] ツールチップテキスト
  def aggregate_cell_tooltip(wday, time_label, count)
    "#{WDAY_LABELS[wday]} #{time_label} - #{count}人"
  end
end
