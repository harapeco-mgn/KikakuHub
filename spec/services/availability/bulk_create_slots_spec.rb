require 'rails_helper'

RSpec.describe Availability::BulkCreateSlots do
  let(:user) { create(:user) }
  let(:category) { "tech" }

  describe '.validate_inputs' do
    it '曜日が空の場合はエラーを返す' do
      error = described_class.validate_inputs(wdays: [], start_minute: 540, end_minute: 600)
      expect(error).to eq("曜日を選択してください")
    end

    it '開始時刻または終了時刻が空の場合はエラーを返す' do
      error = described_class.validate_inputs(wdays: [ 1, 2 ], start_minute: nil, end_minute: 600)
      expect(error).to eq("開始時刻/終了時刻を選択してください")
    end

    it '終了時刻が空の場合もエラーを返す' do
      error = described_class.validate_inputs(wdays: [ 1, 2 ], start_minute: 540, end_minute: nil)
      expect(error).to eq("開始時刻/終了時刻を選択してください")
    end

    it '開始時刻が終了時刻以降の場合はエラーを返す' do
      error = described_class.validate_inputs(wdays: [ 1, 2 ], start_minute: 600, end_minute: 540)
      expect(error).to eq("開始時刻は終了時刻より前にしてください")
    end

    it 'すべて正常な場合はnilを返す' do
      error = described_class.validate_inputs(wdays: [ 1, 2 ], start_minute: 540, end_minute: 600)
      expect(error).to be_nil
    end
  end

  describe '.call' do
    context '新規スロットの追加' do
      it '指定した曜日にスロットを追加する' do
        result = described_class.call(
          user: user,
          category: category,
          wdays: [ 1, 2 ],  # 月曜・火曜
          start_minute: 540,  # 09:00
          end_minute: 600     # 10:00
        )

        expect(result[:created]).to eq(2)
        expect(user.availability_slots.where(wday: 1, category: category).count).to eq(1)
        expect(user.availability_slots.where(wday: 2, category: category).count).to eq(1)
      end
    end

    context '既存スロットとマージされる場合' do
      before do
        # 月曜 09:00-10:00 を事前登録
        create(:availability_slot, user: user, category: category, wday: 1, start_minute: 540, end_minute: 600)
      end

      it '重複する時間帯は統合される' do
        result = described_class.call(
          user: user,
          category: category,
          wdays: [ 1, 2 ],
          start_minute: 570,  # 09:30
          end_minute: 630     # 10:30（既存と重複）
        )

        # 月曜は統合、火曜は新規
        expect(result[:merged]).to eq(1)
        expect(result[:created]).to eq(1)
      end
    end

    context '既存スロットに完全に含まれる場合' do
      before do
        # 月曜 09:00-11:00 を事前登録
        create(:availability_slot, user: user, category: category, wday: 1, start_minute: 540, end_minute: 660)
      end

      it '変更なしとしてカウントされる' do
        result = described_class.call(
          user: user,
          category: category,
          wdays: [ 1 ],
          start_minute: 570,  # 09:30
          end_minute: 630     # 10:30（既存に完全に含まれる）
        )

        expect(result[:unchanged]).to eq(1)
        expect(result[:unchanged_wdays]).to include(1)
      end
    end
  end
end
