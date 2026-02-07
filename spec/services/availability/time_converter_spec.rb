require 'rails_helper'

RSpec.describe Availability::TimeConverter do
  describe '.time_to_minutes' do
    context '正常な時刻文字列の場合' do
      it '"09:00"を分に変換する' do
        expect(described_class.time_to_minutes("09:00")).to eq(540)
      end

      it '"12:30"を分に変換する' do
        expect(described_class.time_to_minutes("12:30")).to eq(750)
      end

      it '"00:00"を分に変換する' do
        expect(described_class.time_to_minutes("00:00")).to eq(0)
      end

      it '"23:59"を分に変換する' do
        expect(described_class.time_to_minutes("23:59")).to eq(1439)
      end

      it '1桁の時間"9:30"を変換する' do
        expect(described_class.time_to_minutes("9:30")).to eq(570)
      end
    end

    context 'nilや空文字列の場合' do
      it 'nilを渡すとnilを返す' do
        expect(described_class.time_to_minutes(nil)).to be_nil
      end

      it '空文字列を渡すとnilを返す' do
        expect(described_class.time_to_minutes("")).to be_nil
      end
    end

    context '整数の場合' do
      it '整数をそのまま返す' do
        expect(described_class.time_to_minutes(540)).to eq(540)
      end
    end

    context '不正な形式の場合' do
      it '時刻以外の文字列はnilを返す' do
        expect(described_class.time_to_minutes("invalid")).to be_nil
      end
    end
  end
end
