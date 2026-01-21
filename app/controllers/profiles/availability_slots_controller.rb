module Profiles
  class AvailabilitySlotsController < ApplicationController
    before_action :authenticate_user!

    def index
      slots = current_user.availability_slots.order(:category, :wday, :start_minute)

      merged_hash =
        slots.group_by { |s| [ s.category, s.wday ] }
             .transform_values do |group|
               ranges = group.map do |s|
                 { start_minute: s.start_minute, end_minute: s.end_minute, ids: [ s.id ] }
               end
               Availability::RangeMerger.call(ranges)
             end

      # 表示順を安定させる（categoryのenum順 → wday順）
      @merged_availability_groups =
        merged_hash.sort_by { |(category, wday), _| [ AvailabilitySlot.categories[category], wday ] }
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

    def edit
      @availability_slot = current_user.availability_slots.find(params[:id])

      # まとめ表示から来たときは結合後の時間を初期表示
      if params[:merged_start].present? && params[:merged_end].present?
        @availability_slot.start_time = hhmm(params[:merged_start].to_i)
        @availability_slot.end_time   = hhmm(params[:merged_end].to_i)
      else
        # 通常の編集（単体レコード）
        @availability_slot.start_time = hhmm(@availability_slot.start_minute)
        @availability_slot.end_time   = hhmm(@availability_slot.end_minute)
      end
    end

    def update
      @availability_slot = current_user.availability_slots.find(params[:id])
      merged_ids = parse_merged_ids

      # まとめ更新（merged_idsがあるなら“まとめ”として扱う）
      if merged_ids.any?
        @availability_slot.assign_attributes(availability_slot_params)

        # blankを選ばれた場合に、古いminuteが残ってvalidにならないようにする
        @availability_slot.start_minute = nil if availability_slot_params[:start_time].blank?
        @availability_slot.end_minute   = nil if availability_slot_params[:end_time].blank?

        if @availability_slot.valid?
          ActiveRecord::Base.transaction do
            current_user.availability_slots.where(id: merged_ids).delete_all
            current_user.availability_slots.create!(availability_slot_params)
          end
          redirect_to profile_availability_slots_path, notice: "参加可能時間を更新しました。"
        else
          render :edit, status: :unprocessable_entity
        end

      # 単体更新（通常）
      else
        if @availability_slot.update(availability_slot_params)
          redirect_to profile_availability_slots_path, notice: "参加可能時間を更新しました。"
        else
          render :edit, status: :unprocessable_entity
        end
      end
    end

    def destroy
      merged_ids = parse_merged_ids

      if merged_ids.any?
        current_user.availability_slots.where(id: merged_ids).destroy_all
      else
        current_user.availability_slots.find(params[:id]).destroy!
      end

      redirect_to profile_availability_slots_path, notice: "削除しました。"
    end

    private

    def availability_slot_params
      params.require(:availability_slot).permit(:category, :wday, :start_time, :end_time)
    end

    def parse_merged_ids
      params[:merged_ids].to_s.split(",").map(&:to_i).uniq
    end

    def hhmm(min)
      format("%02d:%02d", min / 60, min % 60)
    end
  end
end
