module Notifications
  class CreateNotificationJob < ApplicationJob
    queue_as :default

    def perform(recipient_ids:, actor_id:, notifiable_type:, notifiable_id:, action_type:)
      recipients = User.where(id: recipient_ids)
      actor      = User.find(actor_id)
      notifiable = notifiable_type.constantize.find(notifiable_id)

      Notifications::CreateNotification.call(
        recipients: recipients.to_a,
        actor: actor,
        notifiable: notifiable,
        action_type: action_type.to_sym
      )
    end
  end
end
