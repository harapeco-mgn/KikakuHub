require 'rails_helper'

RSpec.describe "Themes ExpiresAt", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before { sign_in user }

  describe "テーマ作成・編集" do
    context "POST /themes" do
      it "expires_atを設定してテーマを作成できる" do
        expires = 7.days.from_now
        post themes_path, params: {
          theme: {
            category: "tech",
            title: "期限ありテーマ",
            description: "テスト",
            expires_at: expires.strftime("%Y-%m-%dT%H:%M")
          }
        }
        expect(response).to redirect_to(theme_path(Theme.last))
        expect(Theme.last.expires_at).to be_within(1.minute).of(expires)
      end

      it "expires_atを設定せずにテーマを作成できる" do
        post themes_path, params: {
          theme: {
            category: "tech",
            title: "期限なしテーマ",
            description: "テスト"
          }
        }
        expect(response).to redirect_to(theme_path(Theme.last))
        expect(Theme.last.expires_at).to be_nil
      end
    end
  end

  describe "投票の期限切れガード" do
    let(:active_theme) { create(:theme, expires_at: 3.days.from_now) }
    let(:expired_theme) { create(:theme, expires_at: 1.day.ago) }
    let(:no_expiry_theme) { create(:theme, expires_at: nil) }

    context "期限内のテーマ" do
      it "投票できる" do
        post theme_vote_path(active_theme)
        expect(response).to redirect_to(active_theme)
        expect(flash[:notice]).to eq("投票しました")
      end
    end

    context "期限のないテーマ" do
      it "投票できる" do
        post theme_vote_path(no_expiry_theme)
        expect(response).to redirect_to(no_expiry_theme)
        expect(flash[:notice]).to eq("投票しました")
      end
    end

    context "期限切れのテーマ" do
      it "投票できずリダイレクトされる" do
        post theme_vote_path(expired_theme)
        expect(response).to redirect_to(expired_theme)
        expect(flash[:alert]).to eq("募集期限が終了しているため、投票できません。")
      end
    end
  end

  describe "参加表明の期限切れガード" do
    let(:active_theme) { create(:theme, expires_at: 3.days.from_now) }
    let(:expired_theme) { create(:theme, expires_at: 1.day.ago) }
    let(:no_expiry_theme) { create(:theme, expires_at: nil) }
    let(:turbo_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }

    context "期限内のテーマ" do
      it "参加表明できる" do
        patch theme_rsvp_path(active_theme), params: { rsvp: { status: "attending" } },
              headers: turbo_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context "期限のないテーマ" do
      it "参加表明できる" do
        patch theme_rsvp_path(no_expiry_theme), params: { rsvp: { status: "attending" } },
              headers: turbo_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context "期限切れのテーマ" do
      it "参加表明できず422を返す" do
        patch theme_rsvp_path(expired_theme), params: { rsvp: { status: "attending" } },
              headers: turbo_headers
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
