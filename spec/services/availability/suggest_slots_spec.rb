require "rails_helper"

RSpec.describe Availability::SuggestSlots do
  describe ".call" do
    def empty_counts
      Array.new(7) { Array.new(48, 0) }
    end

    context "データがない場合" do
      it "空配列を返す" do
        expect(described_class.call(empty_counts)).to eq([])
      end

      it "nilを渡しても空配列を返す" do
        expect(described_class.call(nil)).to eq([])
      end
    end

    context "1時間未満のスロットのみの場合" do
      it "候補に含まれない" do
        counts = empty_counts
        # 月曜 09:00-09:30 のみ（1スロット）
        counts[1][18] = 3

        expect(described_class.call(counts)).to eq([])
      end
    end

    context "1時間以上の連続スロットがある場合" do
      it "候補として返す" do
        counts = empty_counts
        # 月曜 09:00-10:00（2スロット）
        counts[1][18] = 3
        counts[1][19] = 3

        result = described_class.call(counts)

        expect(result.size).to eq(1)
        expect(result[0]).to include(
          wday: 1,
          start_minute: 540,
          end_minute: 600,
          min_count: 3,
          slots: 2
        )
      end
    end

    context "複数の候補がある場合" do
      it "min_count降順でソートされる" do
        counts = empty_counts
        # 月曜 09:00-10:00: 2人
        counts[1][18] = 2
        counts[1][19] = 2
        # 水曜 19:00-20:00: 5人
        counts[3][38] = 5
        counts[3][39] = 5

        result = described_class.call(counts)

        expect(result.size).to eq(2)
        expect(result[0][:wday]).to eq(3)
        expect(result[0][:min_count]).to eq(5)
        expect(result[1][:wday]).to eq(1)
        expect(result[1][:min_count]).to eq(2)
      end

      it "同じmin_countならslots（時間の長さ）降順" do
        counts = empty_counts
        # 月曜 09:00-10:00: 3人（2スロット）
        counts[1][18] = 3
        counts[1][19] = 3
        # 水曜 19:00-21:00: 3人（4スロット）
        counts[3][38] = 3
        counts[3][39] = 3
        counts[3][40] = 3
        counts[3][41] = 3

        result = described_class.call(counts)

        expect(result[0][:wday]).to eq(3)
        expect(result[0][:slots]).to eq(4)
      end
    end

    context "Top 3の制限" do
      it "最大3件まで返す" do
        counts = empty_counts
        # 4つの候補を作成
        [0, 1, 2, 3].each do |wday|
          counts[wday][18] = 3
          counts[wday][19] = 3
        end

        result = described_class.call(counts)

        expect(result.size).to eq(3)
      end
    end

    context "連続ブロックのmin_count計算" do
      it "ブロック内の最小値がmin_countになる" do
        counts = empty_counts
        # 月曜 09:00-10:30: [5, 2, 5]
        counts[1][18] = 5
        counts[1][19] = 2
        counts[1][20] = 5

        result = described_class.call(counts)

        expect(result[0][:min_count]).to eq(2)
      end
    end

    context "min_participants引数" do
      it "指定した人数未満のスロットを除外する" do
        counts = empty_counts
        # 月曜 09:00-10:00: 1人
        counts[1][18] = 1
        counts[1][19] = 1
        # 水曜 19:00-20:00: 3人
        counts[3][38] = 3
        counts[3][39] = 3

        result = described_class.call(counts, min_participants: 2)

        expect(result.size).to eq(1)
        expect(result[0][:wday]).to eq(3)
      end
    end

    context "日をまたがないこと" do
      it "異なる曜日のスロットは別ブロックになる" do
        counts = empty_counts
        # 月曜 23:30-24:00
        counts[1][47] = 3
        # 火曜 00:00-00:30
        counts[2][0] = 3

        result = described_class.call(counts)

        # 各1スロット（30分）のみなので候補なし
        expect(result).to eq([])
      end
    end
  end
end
