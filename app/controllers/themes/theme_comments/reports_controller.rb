module Themes
  module ThemeComments
    class ReportsController < Themes::BaseController
      before_action :set_theme_comment

      def create
        authorize @theme_comment, :report?
        @report = @theme_comment.reports.build(report_params)
        @report.reporter = current_user

        if @report.save
          redirect_to theme_path(@theme), notice: "通報を受け付けました。", status: :see_other
        else
          redirect_to theme_path(@theme), alert: @report.errors.full_messages.first, status: :see_other
        end
      end

      private

      def report_params
        params.require(:report).permit(:reason)
      end

      def set_theme_comment
        @theme_comment = @theme.theme_comments.find(params[:theme_comment_id])
      end
    end
  end
end
