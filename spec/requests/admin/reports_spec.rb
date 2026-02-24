require 'rails_helper'

RSpec.describe "Admin::Reports", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:general_user) { create(:user) }
  let(:reporter) { create(:user) }
  let(:theme) { create(:theme) }
  let!(:report) { create(:report, reporter: reporter, reportable: theme) }

  describe "通報一覧 (GET /admin/reports)" do
    context "adminユーザー" do
      before { sign_in admin_user }

      it "通報一覧が表示される" do
        get admin_reports_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "一般ユーザー" do
      before { sign_in general_user }

      it "root_pathにリダイレクトされる" do
        get admin_reports_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "未ログインユーザー" do
      it "ログインページにリダイレクト" do
        get admin_reports_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "通報対応済み (PATCH /admin/reports/:id/review)" do
    context "adminユーザー" do
      before { sign_in admin_user }

      it "ステータスをreviewedに変更できる" do
        patch review_admin_report_path(report)
        expect(report.reload.status).to eq("reviewed")
        expect(response).to redirect_to(admin_reports_path)
      end
    end

    context "一般ユーザー" do
      before { sign_in general_user }

      it "操作できない" do
        patch review_admin_report_path(report)
        expect(report.reload.status).to eq("pending")
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "通報却下 (PATCH /admin/reports/:id/dismiss)" do
    context "adminユーザー" do
      before { sign_in admin_user }

      it "ステータスをdismissedに変更できる" do
        patch dismiss_admin_report_path(report)
        expect(report.reload.status).to eq("dismissed")
        expect(response).to redirect_to(admin_reports_path)
      end
    end

    context "一般ユーザー" do
      before { sign_in general_user }

      it "操作できない" do
        patch dismiss_admin_report_path(report)
        expect(report.reload.status).to eq("pending")
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
