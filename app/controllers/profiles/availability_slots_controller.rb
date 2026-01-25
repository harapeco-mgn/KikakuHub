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

      wday_labels = %w[日 月 火 水 木 金 土]
      unchanged_wdays = Array(result[:unchanged_wdays])
      unchanged_days  = unchanged_wdays.map { |i| wday_labels[i] }.join("、")

      msg = "一括追加しました（追加: #{result[:created]}日 / 統合: #{result[:merged]}日 / 変更なし: #{result[:unchanged]}日）"
      msg += " 変更なし: #{unchanged_days}（既存の時間に含まれる）" if result[:unchanged].to_i.positive?

      redirect_to profile_availability_slots_path(category: @category), notice: msg
    end

    def bulk_update
      @category = params[:category].presence_in(%w[tech community]) || "tech"
      apply_bulk_update!(category: @category, slots_param: params[:slots])

      redirect_to profile_availability_slots_path(category: @category), notice: "保存しました"
    rescue ActiveRecord::RecordInvalid => e
      render_index_with_error("保存に失敗しました: #{e.record.errors.full_messages.first}")
    rescue ActiveRecord::RecordNotUnique
      render_index_with_error("保存に失敗しました: 同じ時間帯が既に登録されています")
    end

    def destroy
      slot = current_user.availability_slots.find(params[:id])
      slot.destroy!
      redirect_to profile_availability_slots_path(category: slot.category), notice: "削除しました"
    end

    def overwrite_copy_category
      from = params.require(:from_category).presence_in(%w[tech community]) || "tech"
      to   = (from == "tech" ? "community" : "tech")

      # 画面で編集中の内容をまず保存（未保存new_行も含む）
      @category = from
      apply_bulk_update!(category: from, slots_param: params[:slots])

      # コピー元が0件なら中止
      if current_user.availability_slots.where(category: from).none?
        redirect_to profile_availability_slots_path(category: from),
                    alert: "コピー元（#{Theme.human_enum_name(:category, from)}）に登録がないため実行できません。"
        return
      end

      result = AvailabilitySlot.overwrite_copy_category!(
        user: current_user,
        from_category: from,
        to_category: to
      )

      Availability::WeeklySlotNormalizer.call(user: current_user, category: to)

      from_label = Theme.human_enum_name(:category, from)
      to_label   = Theme.human_enum_name(:category, to)

      notice = "#{to_label}へ上書きコピーしました（#{from_label}を保存 → #{to_label}を更新）。" \
               "（既存#{result[:deleted]}件削除 / #{result[:created]}件コピー）" \
               " 確認するにはカテゴリを切り替えてください。"

      redirect_to profile_availability_slots_path(category: from), notice: notice
    rescue ActiveRecord::RecordInvalid => e
      render_index_with_error("保存に失敗したためコピーできませんでした: #{e.record.errors.full_messages.first}")
    rescue ActiveRecord::RecordNotUnique
      render_index_with_error("保存に失敗したためコピーできませんでした: 同じ時間帯が既に登録されています")
    end

    def destroy_all
      category = params.require(:category).presence_in(%w[tech community]) || "tech"

      deleted = current_user.availability_slots.where(category: category).delete_all

      redirect_to profile_availability_slots_path(category: category),
                  notice: "#{Theme.human_enum_name(:category, category)}の参加可能時間を#{deleted}件削除しました。"
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

    # --- ここが bulk_update / overwrite_copy_category 共通の保存処理 ---
    def apply_bulk_update!(category:, slots_param:)
      slots_hash = normalize_slots_hash(slots_param)

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
              category: (p[:category].presence || category),
              start_minute: start_minute,
              end_minute: end_minute
            )
          else
            slot = current_user.availability_slots.find(key)
            raise ActiveRecord::RecordInvalid.new(slot) if start_minute.nil? || end_minute.nil? || start_minute >= end_minute
            slot.update!(start_minute: start_minute, end_minute: end_minute)
          end
        end

        Availability::WeeklySlotNormalizer.call(user: current_user, category: category)
      end
    end

    def normalize_slots_hash(slots_param)
      h = slots_param || {}
      h = h.to_unsafe_h if h.is_a?(ActionController::Parameters)
      h
    end

    def render_index_with_error(message)
      slots = current_user.availability_slots.where(category: @category)
      @slots_by_wday = slots.group_by(&:wday)
      flash.now[:alert] = message
      render :index, status: :unprocessable_entity
    end
  end
end
