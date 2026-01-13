class ThemesController < ApplicationController
  before_action :authenticate_user!

  def index
    @themes = Theme.order(created_at: :desc)
  end

  def show
    @theme = Theme.find(params[:id])
  end

  def new
    @theme = Theme.new
  end

  def create
    @theme = current_user.themes.build(theme_params)
    @theme.community_id = 1 #MVPなので仮で1をセット

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
end