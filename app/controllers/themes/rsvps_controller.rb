class Themes::RsvpsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_theme

  def update
    @rsvp = current_user.rsvps.find_or_initialize_by(theme: @theme)

    if @rsvp.update(rsvp_params)
      redirect_to @theme, notice: "参加状態を更新しました。"
    else
      redirect_to @theme, alert: "更新に失敗しました。"
    end
  end

  private

  def set_theme
    @theme = Theme.find(params[:theme_id])
  end

  def rsvp_params
    params.require(:rsvp).permit(:status, :secondary_interest)
  end
end