# frozen_string_literal: true

module Notifications
  # 通知を一括作成するサービスクラス
  # actor自身への通知を除外し、insert_allで効率的に作成する
  class CreateNotification
    def self.call(recipients:, actor:, notifiable:, action_type:)
      new(recipients: recipients, actor: actor, notifiable: notifiable, action_type: action_type).call
    end

    def initialize(recipients:, actor:, notifiable:, action_type:)
      @recipients = recipients
      @actor = actor
      @notifiable = notifiable
      @action_type = action_type
    end

    def call
      target_recipients = @recipients.uniq.reject { |r| r.id == @actor.id }
      return if target_recipients.empty?

      now = Time.current
      records = target_recipients.map do |recipient|
        {
          user_id: recipient.id,
          actor_id: @actor.id,
          notifiable_type: @notifiable.class.name,
          notifiable_id: @notifiable.id,
          action_type: Notification.action_types[@action_type],
          read_at: nil,
          created_at: now,
          updated_at: now
        }
      end

      Notification.insert_all(records)
    end
  end
end
