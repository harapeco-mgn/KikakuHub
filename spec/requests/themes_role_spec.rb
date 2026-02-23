require 'rails_helper'

RSpec.describe "Themes Role Authorization", type: :request do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:editor_user) { create(:user, :editor) }
  let(:admin_user) { create(:user, :admin) }
  let(:theme) { create(:theme, user: owner, status: :considering) }

  describe "テーマ編集 (PATCH /themes/:id)" do
    context "editorユーザーが他ユーザーのテーマを編集" do
      before { sign_in editor_user }

      it "編集できる" do
        patch theme_path(theme), params: { theme: { title: "編集後タイトル" } }
        expect(theme.reload.title).to eq("編集後タイトル")
        expect(response).to redirect_to(theme)
      end
    end

    context "generalユーザーが他ユーザーのテーマを編集" do
      before { sign_in other_user }

      it "編集できない" do
        original_title = theme.title
        patch theme_path(theme), params: { theme: { title: "不正編集" } }
        expect(theme.reload.title).to eq(original_title)
        expect(response).to redirect_to(root_path)
      end
    end

    context "adminユーザーが他ユーザーのテーマを編集" do
      before { sign_in admin_user }

      it "編集できる" do
        patch theme_path(theme), params: { theme: { title: "admin編集後タイトル" } }
        expect(theme.reload.title).to eq("admin編集後タイトル")
        expect(response).to redirect_to(theme)
      end
    end
  end

  describe "テーマ削除 (DELETE /themes/:id)" do
    context "editorユーザーが他ユーザーのテーマを削除" do
      before { sign_in editor_user }

      it "削除できる" do
        delete theme_path(theme)
        expect(Theme.exists?(theme.id)).to be false
        expect(response).to redirect_to(themes_path)
      end
    end

    context "generalユーザーが他ユーザーのテーマを削除" do
      before { sign_in other_user }

      it "削除できない" do
        delete theme_path(theme)
        expect(Theme.exists?(theme.id)).to be true
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "状態遷移 (PATCH /themes/:id/transition)" do
    context "editorユーザーが他ユーザーのテーマの状態遷移" do
      before { sign_in editor_user }

      it "状態遷移できない" do
        patch transition_theme_path(theme), params: { theme: { status: "confirmed", converted_event_url: "https://example.com" } }
        expect(theme.reload).to be_considering
        expect(response).to redirect_to(root_path)
      end
    end

    context "adminユーザーが他ユーザーのテーマの状態遷移" do
      before { sign_in admin_user }

      it "状態遷移できる" do
        patch transition_theme_path(theme), params: { theme: { status: "confirmed", converted_event_url: "https://example.com" } }
        expect(theme.reload).to be_confirmed
        expect(response).to redirect_to(theme)
      end
    end

    context "generalユーザーが他ユーザーのテーマの状態遷移" do
      before { sign_in other_user }

      it "状態遷移できない" do
        patch transition_theme_path(theme), params: { theme: { status: "confirmed" } }
        expect(theme.reload).to be_considering
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
