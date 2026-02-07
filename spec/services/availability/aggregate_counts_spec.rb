require 'rails_helper'

RSpec.describe Availability::AggregateCounts do
  let(:user1) { create(:user, cohort: 1) }
  let(:user2) { create(:user, cohort: 1) }
  let(:user3) { create(:user, cohort: 2) }
  let(:category) { "tech" }

  describe '.call' do
    context '基本的な集計' do
      before do
        # user1: 月曜 09:00-10:00
        create(:availability_slot, user: user1, category: category, wday: 1, start_minute: 540, end_minute: 600)
        # user2: 月曜 09:30-10:30
        create(:availability_slot, user: user2, category: category, wday: 1, start_minute: 570, end_minute: 630)
      end

      it '30分ごとの参加可能人数を集計する' do
        result = described_class.call(cohort: "all", category: category)

        # 月曜 09:00-09:30: user1のみ
        expect(result[1][18]).to eq(1)  # wday=1, index=18 (09:00)
        # 月曜 09:30-10:00: user1 + user2
        expect(result[1][19]).to eq(2)  # wday=1, index=19 (09:30)
        # 月曜 10:00-10:30: user2のみ
        expect(result[1][20]).to eq(1)  # wday=1, index=20 (10:00)
      end
    end

    context 'cohortフィルター' do
      before do
        create(:availability_slot, user: user1, category: category, wday: 1, start_minute: 540, end_minute: 600)
        create(:availability_slot, user: user2, category: category, wday: 1, start_minute: 540, end_minute: 600)
        create(:availability_slot, user: user3, category: category, wday: 1, start_minute: 540, end_minute: 600)
      end

      it 'cohort指定で特定期生のみ集計する' do
        result = described_class.call(cohort: "1", category: category)

        expect(result[1][18]).to eq(2)  # cohort 1のみ（user1, user2）
      end

      it '"all"を指定すると全員を集計する' do
        result = described_class.call(cohort: "all", category: category)

        expect(result[1][18]).to eq(3)  # 全員（user1, user2, user3）
      end
    end

    context 'categoryフィルター' do
      before do
        create(:availability_slot, user: user1, category: "tech", wday: 1, start_minute: 540, end_minute: 600)
        create(:availability_slot, user: user1, category: "community", wday: 1, start_minute: 540, end_minute: 600)
      end

      it '指定されたカテゴリのみ集計される' do
        result_tech = described_class.call(cohort: "all", category: "tech")
        result_community = described_class.call(cohort: "all", category: "community")

        expect(result_tech[1][18]).to eq(1)
        expect(result_community[1][18]).to eq(1)
      end
    end

    context '複数の曜日' do
      before do
        create(:availability_slot, user: user1, category: category, wday: 1, start_minute: 540, end_minute: 600)  # 月曜
        create(:availability_slot, user: user1, category: category, wday: 3, start_minute: 540, end_minute: 600)  # 水曜
      end

      it '各曜日ごとに集計される' do
        result = described_class.call(cohort: "all", category: category)

        expect(result[1][18]).to eq(1)  # 月曜
        expect(result[3][18]).to eq(1)  # 水曜
        expect(result[2][18]).to eq(0)  # 火曜（登録なし）
      end
    end

    context '返り値の構造' do
      it '曜日0-6、時間帯0-47の2次元配列を返す' do
        result = described_class.call(cohort: "all", category: "tech")

        # 7日分の配列
        expect(result.size).to eq(7)

        # 各曜日に48時間帯分
        result.each do |time_slots|
          expect(time_slots.size).to eq(48)
        end
      end
    end
  end
end
