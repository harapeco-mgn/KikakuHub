require 'rails_helper'

RSpec.describe "Reports", type: :request do
  let(:reporter) { create(:user) }
  let(:owner) { create(:user) }
  let(:theme) { create(:theme, user: owner) }

  describe "テーマ通報 (POST /themes/:theme_id/reports)" do
    context "ログインユーザーが他ユーザーのテーマを通報" do
      before { sign_in reporter }

      it "通報できる" do
        expect {
          post theme_reports_path(theme), params: { report: { reason: "不適切なコンテンツ" } }
        }.to change(Report, :count).by(1)
        expect(response).to redirect_to(theme_path(theme))
      end
    end

    context "テーマオーナーが自分のテーマを通報しようとする" do
      before { sign_in owner }

      it "通報できない" do
        expect {
          post theme_reports_path(theme), params: { report: { reason: "通報理由" } }
        }.not_to change(Report, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    context "同じユーザーが重複通報しようとする" do
      before do
        sign_in reporter
        create(:report, reporter: reporter, reportable: theme)
      end

      it "重複通報できない" do
        expect {
          post theme_reports_path(theme), params: { report: { reason: "重複通報" } }
        }.not_to change(Report, :count)
        expect(response).to redirect_to(theme_path(theme))
      end
    end

    context "未ログインユーザー" do
      it "ログインページにリダイレクト" do
        post theme_reports_path(theme), params: { report: { reason: "通報理由" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
