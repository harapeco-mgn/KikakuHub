module Profiles
  class AvailabilitySlotsController < ApplicationController
    before_action :authenticate_user!

    def index
      @availability_slots = current_user.availability_slots.order(:category, :wday, :start_minute)
    end

    def new
      @availability_slot = current_user.availability_slots.new
    end

    def create
      @availability_slot = current_user.availability_slots.new(availability_slot_params)
      if @availability_slot.save
        redirect_to profile_availability_slots_path, notice: "参加可能時間を登録しました。"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      slot = current_user.availability_slots.find(params[:id])
      slot.destroy!
      redirect_to profile_availability_slots_path, notice: "削除しました。"
    end

    private

    def availability_slot_params
      params.require(:availability_slot).permit(:category, :wday, :start_time, :end_time)
    end
  end
end