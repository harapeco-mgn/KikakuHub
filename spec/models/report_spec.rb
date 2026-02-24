require 'rails_helper'

RSpec.describe Report, type: :model do
  describe "バリデーション" do
    let(:reporter) { create(:user) }
    let(:theme) { create(:theme) }

    context "正常なデータ" do
      it "有効なreportを作成できる" do
        report = build(:report, reporter: reporter, reportable: theme)
        expect(report).to be_valid
      end
    end

    context "reasonが空の場合" do
      it "無効" do
        report = build(:report, reporter: reporter, reportable: theme, reason: "")
        expect(report).not_to be_valid
        expect(report.errors[:reason]).to be_present
      end
    end

    context "reasonが500文字超の場合" do
      it "無効" do
        report = build(:report, reporter: reporter, reportable: theme, reason: "a" * 501)
        expect(report).not_to be_valid
      end
    end

    context "同じユーザーが同じコンテンツを重複通報した場合" do
      before { create(:report, reporter: reporter, reportable: theme) }

      it "無効" do
        report = build(:report, reporter: reporter, reportable: theme)
        expect(report).not_to be_valid
        expect(report.errors[:reporter_id]).to be_present
      end
    end

    context "同じユーザーが異なるコンテンツを通報した場合" do
      let(:other_theme) { create(:theme) }

      before { create(:report, reporter: reporter, reportable: theme) }

      it "有効" do
        report = build(:report, reporter: reporter, reportable: other_theme)
        expect(report).to be_valid
      end
    end
  end

  describe "enum :status" do
    it "pending, reviewed, dismissed の3状態を持つ" do
      expect(Report.statuses.keys).to contain_exactly("pending", "reviewed", "dismissed")
    end
  end
end
