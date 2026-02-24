module Themes
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_theme

    private

    def set_theme
      @theme = Theme.find(params[:theme_id])
      unless current_user&.admin? || !@theme.hidden?
        redirect_to themes_path, alert: "このテーマは非表示になっています。", status: :see_other
      end
    end
  end
end
