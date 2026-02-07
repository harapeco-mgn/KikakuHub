require 'rails_helper'

RSpec.describe Availability::WeeklySlotNormalizer do
  let(:user) { create(:user) }
  let(:category) { "tech" }

  describe '.call' do
    context '重複する時間枠がある場合' do
      before do
        # 月曜に重複する2つのスロット
        create(:availability_slot, user: user, category: category, wday: 1, start_minute: 540, end_minute: 600)   # 09:00-10:00
        create(:availability_slot, user: user, category: category, wday: 1, start_minute: 570, end_minute: 630)   # 09:30-10:30
      end

      it '重複するスロットを1つにマージする' do
        described_class.call(user: user, category: category)

        slots = user.availability_slots.where(wday: 1, category: category).order(:start_minute)
        expect(slots.count).to eq(1)
        expect(slots.first.start_minute).to eq(540)
        expect(slots.first.end_minute).to eq(630)
      end
    end

    context '曜日ごとに独立して処理される場合' do
      before do
        # 月曜に重複スロット
        create(:availability_slot, user: user, category: category, wday: 1, start_minute: 540, end_minute: 600)
        create(:availability_slot, user: user, category: category, wday: 1, start_minute: 570, end_minute: 630)
        # 火曜に重複スロット
        create(:availability_slot, user: user, category: category, wday: 2, start_minute: 540, end_minute: 600)
        create(:availability_slot, user: user, category: category, wday: 2, start_minute: 570, end_minute: 630)
      end

      it '各曜日ごとにマージされる' do
        described_class.call(user: user, category: category)

        monday_slots = user.availability_slots.where(wday: 1, category: category)
        tuesday_slots = user.availability_slots.where(wday: 2, category: category)

        expect(monday_slots.count).to eq(1)
        expect(tuesday_slots.count).to eq(1)
      end
    end

    context '重複しない時間枠の場合' do
      before do
        create(:availability_slot, user: user, category: category, wday: 1, start_minute: 540, end_minute: 600)   # 09:00-10:00
        create(:availability_slot, user: user, category: category, wday: 1, start_minute: 720, end_minute: 780)   # 12:00-13:00
      end

      it 'スロット数は変わらない' do
        expect {
          described_class.call(user: user, category: category)
        }.not_to change { user.availability_slots.where(wday: 1, category: category).count }
      end
    end

    context 'スロットがない場合' do
      it 'エラーなく処理される' do
        expect {
          described_class.call(user: user, category: category)
        }.not_to raise_error
      end
    end

    context '他のユーザーやカテゴリに影響しない' do
      let(:other_user) { create(:user) }

      before do
        # 対象ユーザーの対象カテゴリ
        create(:availability_slot, user: user, category: category, wday: 1, start_minute: 540, end_minute: 600)
        create(:availability_slot, user: user, category: category, wday: 1, start_minute: 570, end_minute: 630)
        # 他のユーザー
        create(:availability_slot, user: other_user, category: category, wday: 1, start_minute: 540, end_minute: 600)
        # 他のカテゴリ
        create(:availability_slot, user: user, category: "community", wday: 1, start_minute: 540, end_minute: 600)
      end

      it '指定されたユーザーとカテゴリのみ処理される' do
        described_class.call(user: user, category: category)

        expect(user.availability_slots.where(category: category).count).to eq(1)  # マージされた
        expect(other_user.availability_slots.count).to eq(1)  # 変更なし
        expect(user.availability_slots.where(category: "community").count).to eq(1)  # 変更なし
      end
    end
  end
end
