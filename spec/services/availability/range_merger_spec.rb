require 'rails_helper'

RSpec.describe Availability::RangeMerger do
  describe '.call' do
    context '範囲が重複している場合' do
      it '重複する範囲をマージする' do
        ranges = [
          { start_minute: 60, end_minute: 120, ids: [ 1 ] },   # 01:00-02:00
          { start_minute: 90, end_minute: 150, ids: [ 2 ] }    # 01:30-02:30
        ]
        result = described_class.call(ranges)

        expect(result).to eq([ { start_minute: 60, end_minute: 150, ids: [ 1, 2 ] } ])
      end

      it '完全に含まれる範囲を統合する' do
        ranges = [
          { start_minute: 60, end_minute: 180, ids: [ 1 ] },   # 01:00-03:00
          { start_minute: 90, end_minute: 120, ids: [ 2 ] }    # 01:30-02:00（完全に内側）
        ]
        result = described_class.call(ranges)

        expect(result).to eq([ { start_minute: 60, end_minute: 180, ids: [ 1, 2 ] } ])
      end
    end

    context '範囲が重複していない場合' do
      it '複数の独立した範囲をそのまま返す' do
        ranges = [
          { start_minute: 60, end_minute: 120, ids: [ 1 ] },   # 01:00-02:00
          { start_minute: 180, end_minute: 240, ids: [ 2 ] }   # 03:00-04:00
        ]
        result = described_class.call(ranges)

        expect(result.size).to eq(2)
        expect(result).to include({ start_minute: 60, end_minute: 120, ids: [ 1 ] })
        expect(result).to include({ start_minute: 180, end_minute: 240, ids: [ 2 ] })
      end
    end

    context '空の配列の場合' do
      it '空の配列を返す' do
        expect(described_class.call([])).to eq([])
      end
    end

    context '単一の範囲の場合' do
      it 'そのまま返す' do
        ranges = [ { start_minute: 60, end_minute: 120, ids: [ 1 ] } ]
        result = described_class.call(ranges)

        expect(result).to eq([ { start_minute: 60, end_minute: 120, ids: [ 1 ] } ])
      end
    end

    context '複数の範囲が連続してマージされる場合' do
      it '3つの範囲を1つにマージする' do
        ranges = [
          { start_minute: 60, end_minute: 90, ids: [ 1 ] },    # 01:00-01:30
          { start_minute: 80, end_minute: 120, ids: [ 2 ] },   # 01:20-02:00
          { start_minute: 110, end_minute: 150, ids: [ 3 ] }   # 01:50-02:30
        ]
        result = described_class.call(ranges)

        expect(result).to eq([ { start_minute: 60, end_minute: 150, ids: [ 1, 2, 3 ] } ])
      end
    end

    context 'ids未指定の場合' do
      it '空配列として扱われる' do
        ranges = [
          { start_minute: 60, end_minute: 120 }
        ]
        result = described_class.call(ranges)

        expect(result).to eq([ { start_minute: 60, end_minute: 120, ids: [] } ])
      end
    end
  end
end
