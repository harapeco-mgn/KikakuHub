module Admin
  class ReportsController < BaseController
    before_action :set_report, only: %i[review dismiss]

    def index
      @reports = Report.includes(:reporter, :reportable)
                       .order(created_at: :desc)
                       .page(params[:page]).per(20)
      @reports = @reports.where(status: params[:status]) if params[:status].present?
    end

    def review
      authorize @report
      @report.reviewed!
      redirect_to admin_reports_path, notice: "通報を対応済みにしました。", status: :see_other
    end

    def dismiss
      authorize @report
      @report.dismissed!
      redirect_to admin_reports_path, notice: "通報を却下しました。", status: :see_other
    end

    private

    def set_report
      @report = Report.find(params[:id])
    end
  end
end
