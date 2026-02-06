class ThemesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_theme, only: %i[show destroy]

  def index
    @themes = Theme.order(created_at: :desc)
  end

  def show
    @theme_comment  = ThemeComment.new
    @theme_comments = @theme.theme_comments.includes(:user).order(created_at: :desc)
    @rsvp = current_user.rsvps.find_by(theme: @theme) if user_signed_in?
    @rsvp_counts = @theme.rsvp_counts

    prepare_availability_aggregate
  end

  def new
    @theme = Theme.new
  end

  def create
    @theme = current_user.themes.build(theme_params)
    @theme.community_id = Community::DEFAULT_ID

    if @theme.save
      redirect_to @theme, notice: "テーマが作成されました。", status: :see_other
    else
      flash.now[:alert] = "入力内容を確認してください"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    unless @theme.user == current_user
      redirect_to theme_path(@theme), alert: "削除権限がありません。", status: :see_other
      return
    end

    if @theme.destroy
      redirect_to themes_path, notice: "テーマを削除しました。", status: :see_other
    else
      redirect_to theme_path(@theme), alert: "テーマの削除に失敗しました。", status: :see_other
    end
  end

  private

  def theme_params
    params.require(:theme).permit(:category, :title, :description, :secondary_enabled, :secondary_label)
  end

  def set_theme
    @theme = Theme.find(params[:id])
  end

  # #49/#50: テーマ詳細用の「同カテゴリ集計（期切替）」データを準備
  def prepare_availability_aggregate
    # ?cohort= が空のときも "all" 扱いにしてUI選択状態を安定させる
    @cohort = params[:cohort].presence || "all"

    @availability_category  = @theme.category.to_s
    @availability_supported = %w[tech community].include?(@availability_category)

    return unless @availability_supported

    @cohort_options = User.distinct.order(:cohort).pluck(:cohort).compact

    @availability_counts = Availability::AggregateCounts.call(
      cohort: @cohort,
      category: @availability_category
    )
  end
end
