require 'rails_helper'

RSpec.describe "Themes Transition", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before { sign_in user }

  describe "PATCH /themes/:id/transition" do
    context "considering -> confirmed" do
      let(:theme) { create(:theme, user: user, status: :considering) }

      it "テーマを確定状態に変更できる" do
        patch transition_theme_path(theme), params: { theme: { status: "confirmed", converted_event_url: "https://example.com" } }
        expect(theme.reload).to be_confirmed
        expect(theme.converted_event_url).to eq("https://example.com")
        expect(response).to redirect_to(theme)
      end

      it "URLなしでも確定にできる" do
        patch transition_theme_path(theme), params: { theme: { status: "confirmed" } }
        expect(theme.reload).to be_confirmed
      end
    end

    context "confirmed -> done" do
      let(:theme) { create(:theme, :confirmed, user: user) }

      it "テーマを開催済に変更できる" do
        patch transition_theme_path(theme), params: { theme: { status: "done" } }
        expect(theme.reload).to be_done
        expect(response).to redirect_to(theme)
      end
    end

    context "不正な遷移" do
      let(:theme) { create(:theme, user: user, status: :done) }

      it "done から他の状態への遷移を拒否する" do
        patch transition_theme_path(theme), params: { theme: { status: "considering" } }
        expect(theme.reload).to be_done
        expect(flash[:alert]).to be_present
      end
    end

    context "他ユーザーのテーマ" do
      let(:theme) { create(:theme, user: other_user, status: :considering) }

      it "オーナー以外は遷移できない" do
        patch transition_theme_path(theme), params: { theme: { status: "confirmed" } }
        expect(theme.reload).to be_considering
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
