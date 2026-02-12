module Themes
  class RsvpsController < BaseController
    respond_to :turbo_stream

    def update
      @rsvp = current_user.rsvps.find_or_initialize_by(theme: @theme)
      params_to_update = rsvp_params.to_h.symbolize_keys

      # status を先に assign して、attending? の判定ができるようにする
      if params_to_update.key?(:status)
        @rsvp.assign_attributes(status: params_to_update[:status])
      end

      # secondary_interest を更新しようとしている場合、参加表明が attending でなければ拒否
      if params_to_update.key?(:secondary_interest) && !@rsvp.attending?
        # secondary_interest のみの更新の場合はエラー
        if params_to_update.keys.sort == [ :secondary_interest ]
          @rsvp_counts = @theme.rsvp_counts
          flash.now[:alert] = "参加表明が必要です。"
          render :update, status: :unprocessable_entity
          return
        end
        # status と同時更新の場合は、secondary_interest を無視
        params_to_update.delete(:secondary_interest)
      end

      updated = @rsvp.update(params_to_update)
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
