require "rails_helper"

RSpec.describe "Notifications", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:theme) { create(:theme, user: other_user) }

  before { sign_in user }

  describe "GET /notifications" do
    it "通知一覧ページを表示できる" do
      get notifications_path
      expect(response).to have_http_status(:ok)
    end

    it "自分宛の通知が表示される" do
      create(:notification, user: user, actor: other_user, notifiable: theme)
      get notifications_path
      expect(response.body).to include("確定")
    end
  end

  describe "PATCH /notifications/:id/read" do
    let!(:notification) { create(:notification, user: user, actor: other_user, notifiable: theme) }

    it "通知を既読にしてテーマページへリダイレクトする" do
      patch read_notification_path(notification)
      expect(notification.reload.read?).to be true
      expect(response).to redirect_to(theme_path(theme))
    end

    it "他ユーザーの通知は既読にできない" do
      other_notification = create(:notification, user: other_user, actor: user, notifiable: theme)
      patch read_notification_path(other_notification)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /notifications/read_all" do
    it "すべての未読通知を既読にする" do
      create_list(:notification, 3, user: user, actor: other_user, notifiable: theme)
      patch read_all_notifications_path
      expect(user.notifications.unread.count).to eq(0)
      expect(response).to redirect_to(notifications_path)
    end
  end

  context "未ログインの場合" do
    before { sign_out user }

    it "通知一覧へのアクセスはログインページへリダイレクトされる" do
      get notifications_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
