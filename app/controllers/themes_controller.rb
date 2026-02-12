class ThemesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_theme, only: %i[show edit update destroy transition]

  def index
    @themes = Theme.active_themes
    @themes = @themes.search_by_keyword(params[:keyword]) if params[:keyword].present?
    @themes = @themes.by_category(params[:category]) if params[:category].present?
    @themes = @themes.recent.page(params[:page]).per(20)
  end

  def archived
    @themes = Theme.archived_themes.recent.page(params[:page]).per(20)
  end

  def show
    @theme_comment  = ThemeComment.new
    @theme_comments = @theme.theme_comments.includes(:user).order(created_at: :desc)
    @rsvp = current_user.rsvps.find_by(theme: @theme) if user_signed_in?
    @rsvp_counts = @theme.rsvp_counts
    @hosting_ease = @theme.hosting_ease_score

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

  def edit
    authorize_owner!(@theme)
  end

  def update
    authorize_owner!(@theme)

    if @theme.update(theme_params)
      redirect_to @theme, notice: "テーマを更新しました。", status: :see_other
    else
      flash.now[:alert] = "入力内容を確認してください"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_owner!(@theme, theme_path(@theme))

    if @theme.destroy
      redirect_to themes_path, notice: "テーマを削除しました。", status: :see_other
    else
      redirect_to theme_path(@theme), alert: "テーマの削除に失敗しました。", status: :see_other
    end
  end

  def transition
    authorize_owner!(@theme)
    return if performed?

    new_status = transition_params[:status]

    unless valid_transition?(new_status)
      redirect_to @theme, alert: "この状態遷移は許可されていません。", status: :see_other
      return
    end

    attrs = { status: new_status }
    attrs[:converted_event_url] = transition_params[:converted_event_url] if new_status == "confirmed"

    if @theme.update(attrs)
      redirect_to @theme, notice: status_change_message(new_status), status: :see_other
    else
      redirect_to @theme, alert: "状態の変更に失敗しました。", status: :see_other
    end
  end

  private

  def theme_params
    params.require(:theme).permit(:category, :title, :description, :secondary_enabled, :secondary_label, :converted_event_url)
  end

  def transition_params
    params.require(:theme).permit(:status, :converted_event_url)
  end

  def valid_transition?(new_status)
    allowed = {
      "considering" => %w[confirmed archived],
      "confirmed"   => %w[done archived],
      "done"        => [],
      "archived"    => []
    }
    allowed.fetch(@theme.status, []).include?(new_status)
  end

  def status_change_message(new_status)
    case new_status
    when "confirmed" then "テーマを「確定」に変更しました。"
    when "done"      then "テーマを「開催済」に変更しました。"
    when "archived"  then "テーマをアーカイブしました。"
    else "状態を変更しました。"
    end
  end

  def set_theme
    @theme = Theme.find(params[:id])
  end

  # #49/#50: テーマ詳細用の「同カテゴリ集計（期切替）」データを準備
  def prepare_availability_aggregate
    # ?cohort= が空のときも "all" 扱いにしてUI選択状態を安定させる
    @cohort = params[:cohort].presence || "all"

    @availability_category  = @theme.category.to_s
    @availability_supported = Theme::CATEGORY_KEYS.include?(@availability_category)

    return unless @availability_supported

    @cohort_options = User.cohort_options

    @availability_counts = Availability::AggregateCounts.call(
      cohort: @cohort,
      category: @availability_category
    )

    @suggested_slots = Availability::SuggestSlots.call(@availability_counts)
  end
end
