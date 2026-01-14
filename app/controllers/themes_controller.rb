class ThemesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_theme, only: [:show]
  
  def index
    @themes = Theme.order(created_at: :desc)
  end

  def show
    @theme = Theme.find(params[:id])
    @theme_comment  = ThemeComment.new
    @theme_comments = @theme.theme_comments.includes(:user).order(created_at: :desc)
    @rsvp = current_user.rsvps.find_by(theme: @theme) if user_signed_in?
  end

  def new
    @theme = Theme.new
  end

  def create
    @theme = current_user.themes.build(theme_params)
    @theme.community_id = 1 # MVPなので仮で1をセット

    if @theme.save
      redirect_to @theme, notice: "テーマが作成されました。"
    else
      render :new, alert: "テーマの作成に失敗しました。"
    end
  end

  private

  def theme_params
    params.require(:theme).permit(:category, :title, :description)
  end

  def set_theme
    @theme = Theme.find(params[:id])
  end
end
