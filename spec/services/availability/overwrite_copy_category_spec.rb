require 'rails_helper'

RSpec.describe Availability::OverwriteCopyCategory do
  let(:user) { create(:user) }
  let(:from_category) { "tech" }
  let(:to_category) { "community" }

  describe '.call' do
    context '基本的なコピー' do
      before do
        create(:availability_slot, user: user, category: from_category, wday: 1, start_minute: 540, end_minute: 600)
        create(:availability_slot, user: user, category: from_category, wday: 2, start_minute: 720, end_minute: 780)
      end

      it 'コピー元のスロットをコピー先に複製する' do
        result = described_class.call(user: user, from_category: from_category, to_category: to_category)

        expect(result[:created]).to eq(2)
        expect(user.availability_slots.where(category: to_category).count).to eq(2)

        copied_slots = user.availability_slots.where(category: to_category).order(:wday, :start_minute)
        expect(copied_slots.first.wday).to eq(1)
        expect(copied_slots.first.start_minute).to eq(540)
        expect(copied_slots.last.wday).to eq(2)
      end

      it 'コピー元のスロットは削除されない' do
        described_class.call(user: user, from_category: from_category, to_category: to_category)

        expect(user.availability_slots.where(category: from_category).count).to eq(2)
      end
    end

    context 'コピー先に既存スロットがある場合' do
      before do
        # コピー元
        create(:availability_slot, user: user, category: from_category, wday: 1, start_minute: 540, end_minute: 600)
        # コピー先（上書きされる）
        create(:availability_slot, user: user, category: to_category, wday: 2, start_minute: 720, end_minute: 780)
      end

      it '既存スロットを削除してからコピーする' do
        result = described_class.call(user: user, from_category: from_category, to_category: to_category)

        expect(result[:deleted]).to eq(1)
        expect(result[:created]).to eq(1)

        # コピー先は上書きされている
        expect(user.availability_slots.where(category: to_category).count).to eq(1)
        expect(user.availability_slots.where(category: to_category).first.wday).to eq(1)
      end
    end

    context '重複するスロットがある場合' do
      before do
        # コピー元に異なる時間帯で2つ作成（DBのユニーク制約により同じスロットは作成できない）
        create(:availability_slot, user: user, category: from_category, wday: 1, start_minute: 540, end_minute: 600)
        create(:availability_slot, user: user, category: from_category, wday: 1, start_minute: 600, end_minute: 660)
      end

      it '複数のスロットをコピーする' do
        result = described_class.call(user: user, from_category: from_category, to_category: to_category)

        expect(result[:created]).to eq(2)
        expect(user.availability_slots.where(category: to_category).count).to eq(2)
      end
    end

    context 'トランザクション' do
      before do
        create(:availability_slot, user: user, category: from_category, wday: 1, start_minute: 540, end_minute: 600)
        create(:availability_slot, user: user, category: to_category, wday: 2, start_minute: 720, end_minute: 780)
      end

      it '削除とコピーが1つのトランザクションで実行される' do
        allow(AvailabilitySlot).to receive(:insert_all).and_raise(ActiveRecord::StatementInvalid)

        expect {
          described_class.call(user: user, from_category: from_category, to_category: to_category)
        }.to raise_error(ActiveRecord::StatementInvalid)

        # ロールバックされて、コピー先の既存スロットは削除されていない
        expect(user.availability_slots.where(category: to_category).count).to eq(1)
      end
    end

    context 'コピー元が空の場合' do
      before do
        # コピー先に既存スロット
        create(:availability_slot, user: user, category: to_category, wday: 2, start_minute: 720, end_minute: 780)
      end

      it 'コピー先を削除するだけ' do
        result = described_class.call(user: user, from_category: from_category, to_category: to_category)

        expect(result[:deleted]).to eq(1)
        expect(result[:created]).to eq(0)
        expect(user.availability_slots.where(category: to_category).count).to eq(0)
      end
    end

    context '他のユーザーに影響しない' do
      let(:other_user) { create(:user) }

      before do
        create(:availability_slot, user: user, category: from_category, wday: 1, start_minute: 540, end_minute: 600)
        create(:availability_slot, user: other_user, category: to_category, wday: 2, start_minute: 720, end_minute: 780)
      end

      it '指定されたユーザーのみ処理される' do
        described_class.call(user: user, from_category: from_category, to_category: to_category)

        # other_userのスロットは変更されない
        expect(other_user.availability_slots.count).to eq(1)
      end
    end
  end
end
