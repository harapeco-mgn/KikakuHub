# frozen_string_literal: true

require "rails_helper"

RSpec.describe Themes::HostingEaseCalculator, type: :service do
  let(:user) { create(:user) }
  let(:community) { create(:community) }
  let(:theme) { create(:theme, community: community, user: user, category: :tech) }

  # 各テスト前に既存のAvailabilitySlotをクリア
  before do
    AvailabilitySlot.delete_all
  end

  describe ".call" do
    subject(:result) { described_class.call(theme) }

    context "データが全くない場合" do
      it "スコアが0になる" do
        expect(result[:score]).to eq(0)
      end

      it "内訳が全て0になる" do
        expect(result[:breakdown][:votes]).to eq(0)
        expect(result[:breakdown][:rsvp]).to eq(0)
        expect(result[:breakdown][:availability]).to eq(0)
      end
    end

    context "投票データのみがある場合" do
      before do
        create_list(:theme_vote, 5, theme: theme)
        theme.reload
      end

      it "投票に基づいたスコアが算出される" do
        expect(result[:score]).to be > 0
        expect(result[:breakdown][:votes]).to be > 0
        expect(result[:breakdown][:rsvp]).to eq(0)
        expect(result[:breakdown][:availability]).to eq(0)
      end

      it "投票数が正しく記録される" do
        expect(result[:raw_data][:votes_count]).to eq(5)
      end
    end

    context "参加表明データのみがある場合" do
      before do
        create(:rsvp, theme: theme, user: user, status: :attending)
        create(:rsvp, theme: theme, user: create(:user), status: :attending)
        create(:rsvp, theme: theme, user: create(:user), status: :not_attending)
      end

      it "参加表明に基づいたスコアが算出される" do
        expect(result[:score]).to be > 0
        expect(result[:breakdown][:votes]).to eq(0)
        expect(result[:breakdown][:rsvp]).to be > 0
        expect(result[:breakdown][:availability]).to eq(0)
      end

      it "参加率が正しく記録される" do
        expect(result[:raw_data][:rsvp_rate]).to be_within(0.01).of(2.0 / 3.0)
      end
    end

    context "全てのデータがある場合" do
      let(:other_users) { create_list(:user, 3) }

      before do
        # 投票データ
        create_list(:theme_vote, 10, theme: theme)
        theme.reload

        # 参加表明データ
        create(:rsvp, theme: theme, user: user, status: :attending)
        other_users.each do |u|
          create(:rsvp, theme: theme, user: u, status: :attending)
        end

        # 参加可能時間データ
        [user, *other_users].each do |u|
          create(:availability_slot, user: u, category: :tech, wday: 2, start_minute: 540, end_minute: 600)
        end
      end

      it "全ての要素を組み合わせたスコアが算出される" do
        expect(result[:score]).to be > 0
        expect(result[:breakdown][:votes]).to be > 0
        expect(result[:breakdown][:rsvp]).to be > 0
        expect(result[:breakdown][:availability]).to be > 0
      end

      it "スコアが100以下になる" do
        expect(result[:score]).to be <= 100
      end

      it "内訳の合計がスコアとほぼ一致する" do
        total = result[:breakdown][:votes] + result[:breakdown][:rsvp] + result[:breakdown][:availability]
        expect(total).to be_within(1).of(result[:score])
      end
    end

    context "投票数が上限を超える場合" do
      before do
        create_list(:theme_vote, 25, theme: theme)
        theme.reload
      end

      it "投票コンポーネントが上限値(30)を超えない" do
        expect(result[:breakdown][:votes]).to be <= 30
      end
    end

    context "参加率が100%の場合" do
      before do
        5.times do
          create(:rsvp, theme: theme, user: create(:user), status: :attending)
        end
      end

      it "RSVPコンポーネントが上限値(30)になる" do
        expect(result[:breakdown][:rsvp]).to eq(30.0)
      end
    end
  end

  describe "#calculate" do
    subject(:calculator) { described_class.new(theme) }

    it "正しい構造のハッシュを返す" do
      result = calculator.calculate

      expect(result).to include(:score, :breakdown, :raw_data)
      expect(result[:breakdown]).to include(:votes, :rsvp, :availability)
      expect(result[:raw_data]).to include(:votes_count, :rsvp_rate, :availability_count)
    end
  end
end
