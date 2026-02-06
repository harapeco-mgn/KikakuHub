module Profiles
  class AvailabilitySlotsController < ApplicationController
    before_action :authenticate_user!

    def index
      @category = params[:category].presence_in(Theme::CATEGORY_KEYS) || "tech"
      slots = current_user.availability_slots.where(category: @category)
      @slots_by_wday = slots.group_by(&:wday)
    end

    def bulk_create
      @category = bulk_params[:category].presence_in(Theme::CATEGORY_KEYS) || "tech"

      wdays = Array(bulk_params[:wdays]).reject(&:blank?).map(&:to_i).uniq
      start_minute = Availability::TimeConverter.time_to_minutes(bulk_params[:start_time])
      end_minute   = Availability::TimeConverter.time_to_minutes(bulk_params[:end_time])

      error = Availability::BulkCreateSlots.validate_inputs(
        wdays: wdays, start_minute: start_minute, end_minute: end_minute
      )
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

      redirect_to profile_availability_slots_path(category: @category),
                  notice: bulk_create_notice(result)
    end

    def bulk_update
      @category = params[:category].presence_in(Theme::CATEGORY_KEYS) || "tech"

      Availability::BulkUpdateSlots.call(
        user: current_user, category: @category, slots_param: params[:slots].to_unsafe_h
      )

      redirect_to after_save_path(category: @category), notice: "保存しました"
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
      from = params.require(:from_category).presence_in(Theme::CATEGORY_KEYS) || "tech"
      to   = (from == "tech" ? "community" : "tech")

      @category = from
      Availability::BulkUpdateSlots.call(
        user: current_user, category: from, slots_param: params[:slots].to_unsafe_h
      )

      if current_user.availability_slots.where(category: from).none?
        redirect_to profile_availability_slots_path(category: from),
                    alert: "コピー元（#{Theme.human_enum_name(:category, from)}）に登録がないため実行できません。"
        return
      end

      result = Availability::OverwriteCopyCategory.call(
        user: current_user,
        from_category: from,
        to_category: to
      )

      Availability::WeeklySlotNormalizer.call(user: current_user, category: to)

      redirect_to profile_availability_slots_path(category: from),
                  notice: overwrite_copy_notice(from, to, result)
    rescue ActiveRecord::RecordInvalid => e
      render_index_with_error("保存に失敗したためコピーできませんでした: #{e.record.errors.full_messages.first}")
    rescue ActiveRecord::RecordNotUnique
      render_index_with_error("保存に失敗したためコピーできませんでした: 同じ時間帯が既に登録されています")
    end

    def destroy_all
      category = params.require(:category).presence_in(Theme::CATEGORY_KEYS) || "tech"

      deleted = current_user.availability_slots.where(category: category).delete_all

      redirect_to profile_availability_slots_path(category: category),
                  notice: "#{Theme.human_enum_name(:category, category)}の参加可能時間を#{deleted}件削除しました。"
    end

    private

    def bulk_params
      params.require(:bulk).permit(:category, :start_time, :end_time, wdays: [])
    end

    def after_save_path(category:)
      return themes_path if params[:after_save] == "themes"
      profile_availability_slots_path(category: category)
    end

    def bulk_create_notice(result)
      wday_labels = %w[日 月 火 水 木 金 土]
      unchanged_wdays = Array(result[:unchanged_wdays])
      unchanged_days  = unchanged_wdays.map { |i| wday_labels[i] }.join("、")

      msg = "一括追加しました（追加: #{result[:created]}日 / 統合: #{result[:merged]}日 / 変更なし: #{result[:unchanged]}日）"
      msg += " 変更なし: #{unchanged_days}（既存の時間に含まれる）" if result[:unchanged].to_i.positive?
      msg
    end

    def overwrite_copy_notice(from, to, result)
      from_label = Theme.human_enum_name(:category, from)
      to_label   = Theme.human_enum_name(:category, to)

      "#{to_label}へ上書きコピーしました（#{from_label}を保存 → #{to_label}を更新）。" \
      "（既存#{result[:deleted]}件削除 / #{result[:created]}件コピー）" \
      " 確認するにはカテゴリを切り替えてください。"
    end

    def render_index_with_error(message)
      slots = current_user.availability_slots.where(category: @category)
      @slots_by_wday = slots.group_by(&:wday)
      flash.now[:alert] = message
      render :index, status: :unprocessable_entity
    end
  end
end
