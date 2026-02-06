module Themes
  class RsvpsController < BaseController
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

    def rsvp_params
      params.require(:rsvp).permit(:status, :secondary_interest)
    end
  end
end
