class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  enum :action_type, { theme_confirmed: 0, commented: 1, rsvp_attending: 2 }

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    touch(:read_at) unless read?
  end

  def target_theme
    case notifiable
    when Theme then notifiable
    when ThemeComment then notifiable.theme
    when Rsvp then notifiable.theme
    end
  end

  def message
    case action_type
    when "theme_confirmed"
      "「#{target_theme&.title}」が確定しました"
    when "commented"
      "「#{target_theme&.title}」にコメントが投稿されました"
    when "rsvp_attending"
      "「#{target_theme&.title}」に参加表明がありました"
    end
  end
end
