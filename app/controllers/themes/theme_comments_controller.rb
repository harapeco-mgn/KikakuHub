module Themes
  class ThemeCommentsController < ApplicationController
    before_action :authenticate_user!  # Devise: 未ログインならログイン画面へ
    before_action :set_theme           # /themes/:theme_id を使って対象テーマを取得

    def create
      # テーマに紐づくコメントを作る（theme_id は自動で入る）
      @theme_comment = @theme.theme_comments.build(theme_comment_params)
      # なりすまし防止：user_id は current_user から必ずセット
      @theme_comment.user = current_user

      if @theme_comment.save
        redirect_to theme_path(@theme), notice: "コメントを投稿しました。"
      else
        # show を render するために一覧用の変数も用意しておく
        @theme_comments = @theme.theme_comments.includes(:user).order(created_at: :desc)
        render "themes/show", status: :unprocessable_entity
      end
    end

    private

    def set_theme
      @theme = Theme.find(params[:theme_id])
    end

    def theme_comment_params
      params.require(:theme_comment).permit(:body)
    end
  end
end
