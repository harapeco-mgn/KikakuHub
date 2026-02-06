module Themes
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_theme

    private

    def set_theme
      @theme = Theme.find(params[:theme_id])
    end
  end
end
