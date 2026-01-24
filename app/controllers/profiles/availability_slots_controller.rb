module Profiles
  class AvailabilitySlotsController < ApplicationController
    before_action :authenticate_user!

    def index
      @category = params[:category].presence_in(%w[tech community]) || "tech"
      slots = current_user.availability_slots.where(category: @category)
      @slots_by_wday = slots.group_by(&:wday)
    end

    def bulk_update
      @category = params[:category].presence_in(%w[tech community]) || "tech"

      slots_hash = params.fetch(:slots, {})
      slots_hash = slots_hash.to_unsafe_h if slots_hash.is_a?(ActionController::Parameters)

      ActiveRecord::Base.transaction do
        slots_hash.each do |key, attrs|
          attrs = attrs.to_unsafe_h if attrs.is_a?(ActionController::Parameters)
          p = ActionController::Parameters.new(attrs).permit(:start_time, :end_time, :wday, :category)

          if key.to_s.start_with?("new_")
            next if p[:start_time].blank? || p[:end_time].blank?

            current_user.availability_slots.create!(
              wday: p[:wday],
              category: p[:category].presence || @category,
              start_time: p[:start_time],
              end_time: p[:end_time]
            )
          else
            slot = current_user.availability_slots.find(key)
            slot.update!(start_time: p[:start_time], end_time: p[:end_time])
          end
        end
        Availability::WeeklySlotNormalizer.call(user: current_user, category: @category)
      end

      redirect_to profile_availability_slots_path(category: @category), notice: "保存しました"
    rescue ActiveRecord::RecordInvalid => e
      slots = current_user.availability_slots.where(category: @category)
      @slots_by_wday = slots.group_by(&:wday)
      flash.now[:alert] = "保存に失敗しました: #{e.record.errors.full_messages.first}"
      render :index, status: :unprocessable_entity
    end

    def destroy
      slot = current_user.availability_slots.find(params[:id])
      slot.destroy!
      redirect_to profile_availability_slots_path(category: slot.category), notice: "削除しました"
    end
  end
end