module Admin
  class ThemesController < BaseController
    def index
      @themes = Theme.includes(:user).order(created_at: :desc)
                     .page(params[:page]).per(30)
    end

    def show
      @theme = Theme.find(params[:id])
    end
  end
end
