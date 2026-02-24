module Themes
  class ReportsController < BaseController
    def create
      authorize @theme, :report?
      @report = @theme.reports.build(report_params)
      @report.reporter = current_user

      if @report.save
        redirect_to theme_path(@theme), notice: "通報を受け付けました。", status: :see_other
      else
        redirect_to theme_path(@theme), alert: @report.errors.full_messages.first, status: :see_other
      end
    rescue ActiveRecord::RecordNotUnique
      redirect_to theme_path(@theme), alert: "すでにこのコンテンツを通報済みです。", status: :see_other
    end

    private

    def report_params
      params.require(:report).permit(:reason)
    end
  end
end
