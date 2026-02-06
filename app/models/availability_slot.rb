class AvailabilitySlot < ApplicationRecord
  belongs_to :user

  enum category: { tech: 0, community: 1 }

  # フォーム用（"HH:MM"を受け取る）
  attr_accessor :start_time, :end_time

  before_validation :convert_time_strings_to_minutes

  validates :category, presence: true
  validates :wday, presence: true, inclusion: { in: 0..6 }
  validates :start_minute, :end_minute, presence: true
  validate :end_after_start
  validate :minutes_in_30_min_step

  private

  def convert_time_strings_to_minutes
    self.start_minute = Availability::TimeConverter.time_to_minutes(start_time) if start_time.present?
    self.end_minute   = Availability::TimeConverter.time_to_minutes(end_time)   if end_time.present?
  end

  def end_after_start
    return if start_minute.blank? || end_minute.blank?
    errors.add(:end_minute, "は開始より後にしてください") if end_minute <= start_minute
  end

  def minutes_in_30_min_step
    return if start_minute.blank? || end_minute.blank?
    errors.add(:start_minute, "は30分単位で入力してください") unless (start_minute % 30).zero?
    errors.add(:end_minute, "は30分単位で入力してください") unless (end_minute % 30).zero?
  end
end
