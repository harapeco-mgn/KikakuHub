class ThemesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_theme, only: [ :show ]

  def index
    @themes = Theme.order(created_at: :desc)
  end

  def show
    @theme = Theme.find(params[:id])
    @theme_comment  = ThemeComment.new
    @theme_comments = @theme.theme_comments.includes(:user).order(created_at: :desc)
    @rsvp = current_user.rsvps.find_by(theme: @theme) if user_signed_in?
    @rsvp_counts = @theme.rsvp_counts
  end

  def new
    @theme = Theme.new
  end

def create
  @theme = current_user.themes.build(theme_params)
  @theme.community_id = 1

  if @theme.save
    redirect_to @theme, notice: "テーマが作成されました。", status: :see_other
  else
    Rails.logger.info("[debug] env=#{Rails.env} db=#{ActiveRecord::Base.connection_db_config.database}")
    Rails.logger.info("[debug] community_id=#{@theme.community_id.inspect} exists=#{Community.exists?(@theme.community_id)}")
    Rails.logger.info("[debug] errors=#{@theme.errors.full_messages}")

    flash.now[:alert] = "入力内容を確認してください"
    render :new, status: :unprocessable_entity
  end
end

  private

  def theme_params
    params.require(:theme).permit(:category, :title, :description, :secondary_enabled, :secondary_label)
  end

  def set_theme
    @theme = Theme.find(params[:id])
  end
end
