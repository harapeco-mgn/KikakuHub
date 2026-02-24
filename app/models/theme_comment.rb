class ThemeComment < ApplicationRecord
  include Hideable
  include Reportable

  belongs_to :user
  belongs_to :theme

  validates :body, presence: true, length: { maximum: 255 }

  after_create_commit :notify_theme_owner

  private

  def notify_theme_owner
    return if theme.user == user

    Notifications::CreateNotificationJob.perform_later(
      recipient_ids: [ theme.user.id ],
      actor_id: user.id,
      notifiable_type: self.class.name,
      notifiable_id: id,
      action_type: "commented"
    )
  end
end
