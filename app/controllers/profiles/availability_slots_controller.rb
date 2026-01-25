module Profiles
  class AvailabilitySlotsController < ApplicationController
    before_action :authenticate_user!

    def index
      @category = params[:category].presence_in(%w[tech community]) || "tech"
      slots = current_user.availability_slots.where(category: @category)
      @slots_by_wday = slots.group_by(&:wday)
    end

    def bulk_create
      @category = bulk_params[:category].presence_in(%w[tech community]) || "tech"

      wdays = Array(bulk_params[:wdays]).reject(&:blank?).map(&:to_i).uniq
      start_minute = Availability::BulkCreateSlots.time_to_minutes(bulk_params[:start_time])
      end_minute   = Availability::BulkCreateSlots.time_to_minutes(bulk_params[:end_time])

      error = validate_bulk_inputs(wdays, start_minute, end_minute)
      if error
        redirect_to profile_availability_slots_path(category: @category), alert: error
        return
      end

      result = Availability::BulkCreateSlots.call(
  user: current_user,
  category: @category,
  wdays: wdays,
  start_minute: start_minute,
  end_minute: end_minute
)

wday_labels = %w[日 月 火 水 木 金 土] # wday=0が日、6が土

unchanged_wdays = Array(result[:unchanged_wdays])
unchanged_days  = unchanged_wdays.map { |i| wday_labels[i] }.join("、")

msg = "一括追加しました（追加: #{result[:created]}日 / 統合: #{result[:merged]}日 / 変更なし: #{result[:unchanged]}日）"
msg += " 変更なし: #{unchanged_days}（既存の時間に含まれる）" if result[:unchanged].to_i.positive?

redirect_to profile_availability_slots_path(category: @category), notice: msg
    end

    def bulk_update
      @category = params[:category].presence_in(%w[tech community]) || "tech"

      slots_hash = params.fetch(:slots, {})
      slots_hash = slots_hash.to_unsafe_h if slots_hash.is_a?(ActionController::Parameters)

      ActiveRecord::Base.transaction do
        slots_hash.each do |key, attrs|
          attrs = attrs.to_unsafe_h if attrs.is_a?(ActionController::Parameters)
          p = ActionController::Parameters.new(attrs).permit(:start_time, :end_time, :wday, :category)

          start_minute = Availability::BulkCreateSlots.time_to_minutes(p[:start_time])
          end_minute   = Availability::BulkCreateSlots.time_to_minutes(p[:end_time])

          if key.to_s.start_with?("new_")
            next if start_minute.nil? || end_minute.nil?
            next if start_minute >= end_minute

            current_user.availability_slots.create!(
              wday: p[:wday].to_i,
              category: (p[:category].presence || @category),
              start_minute: start_minute,
              end_minute: end_minute
            )
          else
            slot = current_user.availability_slots.find(key)

            # 既存行の更新は、空入力なら弾く（必要なら「空で削除」等の仕様に合わせて調整）
            raise ActiveRecord::RecordInvalid.new(slot) if start_minute.nil? || end_minute.nil? || start_minute >= end_minute

            slot.update!(start_minute: start_minute, end_minute: end_minute)
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
    rescue ActiveRecord::RecordNotUnique
      # unique制約に当たると RecordInvalid では拾えないので追加
      slots = current_user.availability_slots.where(category: @category)
      @slots_by_wday = slots.group_by(&:wday)
      flash.now[:alert] = "保存に失敗しました: 同じ時間帯が既に登録されています"
      render :index, status: :unprocessable_entity
    end

    def destroy
      slot = current_user.availability_slots.find(params[:id])
      slot.destroy!
      redirect_to profile_availability_slots_path(category: slot.category), notice: "削除しました"
    end

    private

    def bulk_params
      params.require(:bulk).permit(:category, :start_time, :end_time, wdays: [])
    end

    def validate_bulk_inputs(wdays, start_minute, end_minute)
      return "曜日を選択してください" if wdays.blank?
      return "開始時刻/終了時刻を選択してください" if start_minute.nil? || end_minute.nil?
      return "開始時刻は終了時刻より前にしてください" if start_minute >= end_minute
      nil
    end
  end
end