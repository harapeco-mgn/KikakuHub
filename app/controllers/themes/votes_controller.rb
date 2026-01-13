module Themes
  class VotesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_theme

    def create
      current_user.theme_votes.create!(theme: @theme)
      redirect_to @theme, notice: "投票しました"
    end

    def destroy
      current_user.theme_votes.find_by!(theme: @theme).destroy!
      redirect_to @theme, notice: "投票を取り消しました"
    end

    private

    def set_theme
      @theme = Theme.find(params[:theme_id])
    end
  end
end