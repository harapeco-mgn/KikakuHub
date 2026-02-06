module Themes
  class VotesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_theme

    def create
      current_user.theme_votes.create!(theme: @theme)
      redirect_to @theme, notice: "投票しました"
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      # 既に投票済み（連打や競合）でもOKにする
      redirect_to @theme, notice: "既に投票済みです"
    end

    def destroy
      vote = current_user.theme_votes.find_by(theme: @theme)

      if vote
        vote.destroy!
        redirect_to @theme, notice: "投票を取り消しました"
      else
        # 既に取消済み（連打など）でもOK
        redirect_to @theme, notice: "既に取り消し済みです"
      end
    end

    private

    def set_theme
      @theme = Theme.find(params[:theme_id])
    end
  end
end
