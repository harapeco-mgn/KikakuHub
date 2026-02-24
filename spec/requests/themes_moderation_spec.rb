require 'rails_helper'

RSpec.describe "Themes Moderation", type: :request do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:editor_user) { create(:user, :editor) }
  let(:admin_user) { create(:user, :admin) }
  let(:theme) { create(:theme, user: owner) }

  describe "テーマ非表示 (PATCH /themes/:id/hide)" do
    context "adminユーザーが非表示にする" do
      before { sign_in admin_user }

      it "非表示にできる" do
        patch hide_theme_path(theme)
        expect(theme.reload.hidden?).to be true
        expect(response).to redirect_to(theme_path(theme))
      end
    end

    context "editorユーザーが非表示にしようとする" do
      before { sign_in editor_user }

      it "非表示にできない" do
        patch hide_theme_path(theme)
        expect(theme.reload.hidden?).to be false
        expect(response).to redirect_to(root_path)
      end
    end

    context "一般ユーザーが非表示にしようとする" do
      before { sign_in other_user }

      it "非表示にできない" do
        patch hide_theme_path(theme)
        expect(theme.reload.hidden?).to be false
        expect(response).to redirect_to(root_path)
      end
    end

    context "未ログインユーザー" do
      it "ログインページにリダイレクト" do
        patch hide_theme_path(theme)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "テーマ非表示解除 (PATCH /themes/:id/unhide)" do
    let(:hidden_theme) { create(:theme, :hidden, user: owner) }

    context "adminユーザーが非表示解除する" do
      before { sign_in admin_user }

      it "非表示解除できる" do
        patch unhide_theme_path(hidden_theme)
        expect(hidden_theme.reload.hidden?).to be false
        expect(response).to redirect_to(theme_path(hidden_theme))
      end
    end

    context "editorユーザーが非表示解除しようとする" do
      before { sign_in editor_user }

      it "非表示解除できない" do
        patch unhide_theme_path(hidden_theme)
        expect(hidden_theme.reload.hidden?).to be true
        # 非表示テーマは set_theme でthemes_pathにリダイレクトされる（Pundit認可まで届かない）
        expect(response).to redirect_to(themes_path)
      end
    end
  end

  describe "非表示テーマへのアクセス (GET /themes/:id)" do
    let(:hidden_theme) { create(:theme, :hidden, user: owner) }

    context "adminユーザー" do
      before { sign_in admin_user }

      it "アクセスできる" do
        get theme_path(hidden_theme)
        expect(response).to have_http_status(:ok)
      end
    end

    context "一般ユーザー" do
      before { sign_in other_user }

      it "テーマ一覧にリダイレクトされる" do
        get theme_path(hidden_theme)
        expect(response).to redirect_to(themes_path)
      end
    end

    context "テーマ作成者" do
      before { sign_in owner }

      it "テーマ一覧にリダイレクトされる（ownerも非表示テーマにアクセス不可）" do
        get theme_path(hidden_theme)
        expect(response).to redirect_to(themes_path)
      end
    end
  end

  describe "テーマ一覧での非表示制御" do
    context "一般ユーザーがアクセス" do
      before { sign_in other_user }

      it "非表示テーマが一覧に表示されない" do
        visible_theme = create(:theme)
        hidden_theme = create(:theme, :hidden)
        get themes_path
        expect(response.body).to include(visible_theme.title)
        expect(response.body).not_to include(hidden_theme.title)
      end
    end
  end
end
