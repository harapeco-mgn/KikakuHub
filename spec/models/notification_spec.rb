require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "アソシエーション" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:actor).class_name("User") }
    it { is_expected.to belong_to(:notifiable) }
  end

  describe "enum" do
    it {
      is_expected.to define_enum_for(:action_type)
        .with_values(theme_confirmed: 0, commented: 1, rsvp_attending: 2)
    }
  end

  describe "スコープ" do
    let(:user) { create(:user) }
    let(:actor) { create(:user) }
    let(:theme) { create(:theme, user: actor) }

    describe ".unread" do
      it "未読通知のみ返す" do
        unread = create(:notification, user: user, actor: actor, notifiable: theme)
        read = create(:notification, :read, user: user, actor: actor, notifiable: theme)
        expect(Notification.unread).to include(unread)
        expect(Notification.unread).not_to include(read)
      end
    end

    describe ".recent" do
      it "作成日時の降順で返す" do
        old = create(:notification, user: user, actor: actor, notifiable: theme, created_at: 2.days.ago)
        new_one = create(:notification, user: user, actor: actor, notifiable: theme, created_at: 1.day.ago)
        expect(Notification.recent.first).to eq(new_one)
        expect(Notification.recent.last).to eq(old)
      end
    end
  end

  describe "#read?" do
    let(:user) { create(:user) }
    let(:actor) { create(:user) }
    let(:theme) { create(:theme, user: actor) }

    it "read_atが設定されている場合はtrueを返す" do
      notification = create(:notification, :read, user: user, actor: actor, notifiable: theme)
      expect(notification.read?).to be true
    end

    it "read_atがnilの場合はfalseを返す" do
      notification = create(:notification, user: user, actor: actor, notifiable: theme)
      expect(notification.read?).to be false
    end
  end

  describe "#mark_as_read!" do
    let(:user) { create(:user) }
    let(:actor) { create(:user) }
    let(:theme) { create(:theme, user: actor) }

    it "read_atを現在時刻で更新する" do
      notification = create(:notification, user: user, actor: actor, notifiable: theme)
      expect { notification.mark_as_read! }.to change { notification.reload.read_at }.from(nil)
    end

    it "既読の場合は更新しない" do
      notification = create(:notification, :read, user: user, actor: actor, notifiable: theme)
      original_read_at = notification.read_at
      notification.mark_as_read!
      expect(notification.reload.read_at).to eq(original_read_at)
    end
  end

  describe "#target_theme" do
    let(:user) { create(:user) }
    let(:actor) { create(:user) }

    context "notifiableがThemeの場合" do
      it "そのThemeを返す" do
        theme = create(:theme, user: actor)
        notification = create(:notification, user: user, actor: actor, notifiable: theme)
        expect(notification.target_theme).to eq(theme)
      end
    end

    context "notifiableがThemeCommentの場合" do
      it "コメントのThemeを返す" do
        theme = create(:theme, user: user)
        comment = create(:theme_comment, user: actor, theme: theme)
        notification = create(:notification, :commented, user: user, actor: actor, notifiable: comment)
        expect(notification.target_theme).to eq(theme)
      end
    end

    context "notifiableがRsvpの場合" do
      it "RsvpのThemeを返す" do
        theme = create(:theme, user: user)
        rsvp = create(:rsvp, user: actor, theme: theme)
        notification = create(:notification, :rsvp_attending, user: user, actor: actor, notifiable: rsvp)
        expect(notification.target_theme).to eq(theme)
      end
    end
  end

  describe "#message" do
    let(:user) { create(:user) }
    let(:actor) { create(:user) }

    it "theme_confirmedの場合に適切なメッセージを返す" do
      theme = create(:theme, user: actor, title: "テストテーマ")
      notification = create(:notification, user: user, actor: actor, notifiable: theme, action_type: :theme_confirmed)
      expect(notification.message).to include("テストテーマ")
      expect(notification.message).to include("確定")
    end

    it "commentedの場合に適切なメッセージを返す" do
      theme = create(:theme, user: user, title: "テストテーマ")
      comment = create(:theme_comment, user: actor, theme: theme)
      notification = create(:notification, :commented, user: user, actor: actor, notifiable: comment)
      expect(notification.message).to include("テストテーマ")
      expect(notification.message).to include("コメント")
    end

    it "rsvp_attendingの場合に適切なメッセージを返す" do
      theme = create(:theme, user: user, title: "テストテーマ")
      rsvp = create(:rsvp, user: actor, theme: theme)
      notification = create(:notification, :rsvp_attending, user: user, actor: actor, notifiable: rsvp)
      expect(notification.message).to include("テストテーマ")
      expect(notification.message).to include("参加表明")
    end
  end
end
