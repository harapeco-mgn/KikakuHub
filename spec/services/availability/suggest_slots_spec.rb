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
          avg_count: 3.0,
          slots: 2
        )
      end
    end

    context "複数の候補がある場合" do
      it "avg_count降順でソートされる" do
        counts = empty_counts
        # 月曜 09:00-10:00: 平均2人
        counts[1][18] = 2
        counts[1][19] = 2
        # 水曜 19:00-20:00: 平均5人
        counts[3][38] = 5
        counts[3][39] = 5

        result = described_class.call(counts)

        expect(result.size).to eq(2)
        expect(result[0][:wday]).to eq(3)
        expect(result[0][:avg_count]).to eq(5.0)
        expect(result[1][:wday]).to eq(1)
        expect(result[1][:avg_count]).to eq(2.0)
      end

      it "同じavg_countならmin_count降順" do
        counts = empty_counts
        # 月曜 09:00-10:00: 平均3人、最低2人
        counts[1][18] = 4
        counts[1][19] = 2
        # 水曜 19:00-20:00: 平均3人、最低3人
        counts[3][38] = 3
        counts[3][39] = 3

        result = described_class.call(counts)

        expect(result[0][:wday]).to eq(3)
        expect(result[0][:min_count]).to eq(3)
        expect(result[1][:wday]).to eq(1)
        expect(result[1][:min_count]).to eq(2)
      end

      it "同じavg_count、min_countならslots（時間の長さ）降順" do
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
        [ 0, 1, 2, 3 ].each do |wday|
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

    context "avg_count（平均参加人数）の計算" do
      it "ブロック内の平均値がavg_countになる" do
        counts = empty_counts
        # 月曜 09:00-10:30: [5, 2, 5] → 平均4.0
        counts[1][18] = 5
        counts[1][19] = 2
        counts[1][20] = 5

        result = described_class.call(counts)

        expect(result[0][:avg_count]).to eq(4.0)
      end
    end

    context "MAX_DURATION_SLOTS（4時間）を超えるブロック" do
      it "最もavg_countが高い4時間のサブウィンドウを返す" do
        counts = empty_counts
        # 月曜 06:00-24:00（36スロット = 18時間）
        # 前半（06:00-14:00）: 1人
        (12..27).each { |slot| counts[1][slot] = 1 }
        # 後半（16:00-22:00）: 5人
        (32..43).each { |slot| counts[1][slot] = 5 }

        result = described_class.call(counts)

        # 最もavg_countが高い8スロット（4時間）が選ばれる
        expect(result[0][:wday]).to eq(1)
        expect(result[0][:slots]).to eq(8)
        expect(result[0][:avg_count]).to eq(5.0)
        # 16:00-20:00 または 18:00-22:00 のいずれか
        expect(result[0][:start_minute]).to be >= 960 # 16:00
        expect(result[0][:end_minute]).to be <= 1320 # 22:00
      end

      it "4時間以下のブロックはそのまま返される" do
        counts = empty_counts
        # 月曜 09:00-12:00（6スロット = 3時間）
        (18..23).each { |slot| counts[1][slot] = 3 }

        result = described_class.call(counts)

        expect(result[0][:slots]).to eq(6)
        expect(result[0][:start_minute]).to eq(540) # 09:00
        expect(result[0][:end_minute]).to eq(720) # 12:00
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
