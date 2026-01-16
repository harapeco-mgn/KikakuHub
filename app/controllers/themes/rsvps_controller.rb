class Themes::RsvpsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_theme
  respond_to :turbo_stream

  def update
    @rsvp = current_user.rsvps.find_or_initialize_by(theme: @theme)

    updated = @rsvp.update(rsvp_params)
    @rsvp_counts = @theme.rsvp_counts

    message = updated ? "参加状態を更新しました。" : "更新に失敗しました。"
    level = updated ? :notice : :alert
    status = updated ? :ok : :unprocessable_entity

    flash.now[level] = message
    render :update, status: status
  end

  private

  def set_theme
    @theme = Theme.find(params[:theme_id])
  end

  def rsvp_params
    params.require(:rsvp).permit(:status, :secondary_interest)
  end
end
