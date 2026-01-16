module Themes
  class ThemeCommentsController < ApplicationController
    before_action :authenticate_user!  # Devise: 未ログインならログイン画面へ
    before_action :set_theme           # /themes/:theme_id を使って対象テーマを取得

    def create
      # テーマに紐づくコメントを作る（theme_id は自動で入る）
      @theme_comment = @theme.theme_comments.build(theme_comment_params)
      # なりすまし防止：user_id は current_user から必ずセット
      @theme_comment.user = current_user

      saved = @theme_comment.save
      load_theme_comments
      @theme_comment = ThemeComment.new if saved

      respond_to do |format|
        format.html do
          if saved
            redirect_to theme_path(@theme), notice: "コメントを投稿しました。"
          else
            load_show_dependencies
            render "themes/show", status: :unprocessable_entity
          end
        end
        format.turbo_stream do
          flash.now[:notice] = "コメントを投稿しました。" if saved
          render :create, status: :unprocessable_entity unless saved
        end
      end
    end

    private

    def set_theme
      @theme = Theme.find(params[:theme_id])
    end

    def theme_comment_params
      params.require(:theme_comment).permit(:body)
    end

    def load_theme_comments
      @theme_comments = @theme.theme_comments.includes(:user).order(created_at: :desc)
    end

    def load_show_dependencies
      @rsvp = current_user.rsvps.find_by(theme: @theme) if user_signed_in?
      @rsvp_counts = @theme.rsvp_counts
    end
  end
end
