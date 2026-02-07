require 'rails_helper'

RSpec.describe Availability::BulkUpdateSlots do
  let(:user) { create(:user) }
  let(:category) { "tech" }

  describe '.call' do
    context '既存スロットの更新' do
      let!(:slot) { create(:availability_slot, user: user, category: category, wday: 1, start_minute: 540, end_minute: 600) }

      it '既存スロットの時間を更新する' do
        slots_param = {
          slot.id.to_s => {
            start_time: "10:00",
            end_time: "11:00"
          }
        }

        described_class.call(user: user, category: category, slots_param: slots_param)

        slot.reload
        expect(slot.start_minute).to eq(600)  # 10:00
        expect(slot.end_minute).to eq(660)    # 11:00
      end

      it '文字列キーでも動作する' do
        slots_param = {
          slot.id.to_s => {
            "start_time" => "10:00",
            "end_time" => "11:00"
          }
        }

        described_class.call(user: user, category: category, slots_param: slots_param)

        slot.reload
        expect(slot.start_minute).to eq(600)
      end
    end

    context '新規スロットの作成' do
      it 'new_で始まるキーは新規作成として扱う' do
        slots_param = {
          "new_1" => {
            wday: 1,
            category: category,
            start_time: "09:00",
            end_time: "10:00"
          }
        }

        expect {
          described_class.call(user: user, category: category, slots_param: slots_param)
        }.to change { user.availability_slots.count }.by(1)

        new_slot = user.availability_slots.last
        expect(new_slot.wday).to eq(1)
        expect(new_slot.start_minute).to eq(540)
      end

      it '開始時刻が終了時刻以降の場合はスキップする' do
        slots_param = {
          "new_1" => {
            wday: 1,
            category: category,
            start_time: "10:00",
            end_time: "09:00"  # 不正
          }
        }

        expect {
          described_class.call(user: user, category: category, slots_param: slots_param)
        }.not_to change { user.availability_slots.count }
      end

      it '時刻がnilの場合はスキップする' do
        slots_param = {
          "new_1" => {
            wday: 1,
            category: category,
            start_time: nil,
            end_time: "10:00"
          }
        }

        expect {
          described_class.call(user: user, category: category, slots_param: slots_param)
        }.not_to change { user.availability_slots.count }
      end
    end

    context 'WeeklySlotNormalizerの呼び出し' do
      it '更新後にWeeklySlotNormalizerが呼ばれる' do
        allow(Availability::WeeklySlotNormalizer).to receive(:call)

        described_class.call(user: user, category: category, slots_param: {})

        expect(Availability::WeeklySlotNormalizer).to have_received(:call).with(user: user, category: category)
      end
    end

    context 'トランザクション' do
      let!(:slot) { create(:availability_slot, user: user, category: category, wday: 1, start_minute: 540, end_minute: 600) }

      it 'エラーが発生した場合はロールバックされる' do
        slots_param = {
          slot.id.to_s => {
            start_time: nil,  # 不正な値
            end_time: "10:00"
          }
        }

        expect {
          described_class.call(user: user, category: category, slots_param: slots_param)
        }.to raise_error(ActiveRecord::RecordInvalid)

        slot.reload
        expect(slot.start_minute).to eq(540)  # 変更されていない
      end
    end
  end
end
