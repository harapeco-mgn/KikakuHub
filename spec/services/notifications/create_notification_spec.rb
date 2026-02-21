require "rails_helper"

RSpec.describe Notifications::CreateNotification, type: :service do
  let(:actor) { create(:user) }
  let(:theme_owner) { create(:user) }
  let(:voter1) { create(:user) }
  let(:voter2) { create(:user) }
  let(:theme) { create(:theme, user: theme_owner) }

  describe ".call" do
    context "複数の受取人への通知作成" do
      it "受取人全員に通知を作成する" do
        expect {
          described_class.call(
            recipients: [ voter1, voter2 ],
            actor: actor,
            notifiable: theme,
            action_type: :theme_confirmed
          )
        }.to change(Notification, :count).by(2)
      end

      it "通知の属性が正しく設定される" do
        described_class.call(
          recipients: [ voter1 ],
          actor: actor,
          notifiable: theme,
          action_type: :theme_confirmed
        )
        notification = Notification.last
        expect(notification.user).to eq(voter1)
        expect(notification.actor).to eq(actor)
        expect(notification.notifiable).to eq(theme)
        expect(notification.action_type).to eq("theme_confirmed")
        expect(notification.read_at).to be_nil
      end
    end

    context "actor自身が受取人に含まれる場合" do
      it "actorへの通知は除外する" do
        expect {
          described_class.call(
            recipients: [ actor, voter1 ],
            actor: actor,
            notifiable: theme,
            action_type: :theme_confirmed
          )
        }.to change(Notification, :count).by(1)

        expect(Notification.last.user).to eq(voter1)
      end
    end

    context "受取人が重複している場合" do
      it "重複を除去して通知を作成する" do
        expect {
          described_class.call(
            recipients: [ voter1, voter1, voter2 ],
            actor: actor,
            notifiable: theme,
            action_type: :theme_confirmed
          )
        }.to change(Notification, :count).by(2)
      end
    end

    context "有効な受取人がいない場合" do
      it "通知を作成しない（actorのみの場合）" do
        expect {
          described_class.call(
            recipients: [ actor ],
            actor: actor,
            notifiable: theme,
            action_type: :theme_confirmed
          )
        }.not_to change(Notification, :count)
      end

      it "空配列の場合も通知を作成しない" do
        expect {
          described_class.call(
            recipients: [],
            actor: actor,
            notifiable: theme,
            action_type: :theme_confirmed
          )
        }.not_to change(Notification, :count)
      end
    end

    context "コメント通知" do
      it "ThemeCommentをnotifiableとして通知を作成する" do
        comment = create(:theme_comment, user: actor, theme: theme)
        expect {
          described_class.call(
            recipients: [ theme_owner ],
            actor: actor,
            notifiable: comment,
            action_type: :commented
          )
        }.to change(Notification, :count).by(1)

        expect(Notification.last.action_type).to eq("commented")
        expect(Notification.last.notifiable).to eq(comment)
      end
    end

    context "参加表明通知" do
      it "Rsvpをnotifiableとしてrsvp_attending通知を作成する" do
        rsvp = create(:rsvp, user: actor, theme: theme, status: :attending)
        expect {
          described_class.call(
            recipients: [ theme_owner ],
            actor: actor,
            notifiable: rsvp,
            action_type: :rsvp_attending
          )
        }.to change(Notification, :count).by(1)

        expect(Notification.last.action_type).to eq("rsvp_attending")
        expect(Notification.last.notifiable).to eq(rsvp)
      end
    end
  end
end
