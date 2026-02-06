require 'rails_helper'

RSpec.describe Community, type: :model do
  describe 'associations' do
    it { should have_many(:themes).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'constants' do
    it 'has DEFAULT_ID constant' do
      expect(Community::DEFAULT_ID).to eq(1)
    end
  end

  describe 'dependent: :restrict_with_error' do
    it 'テーマが存在する場合はコミュニティを削除できない' do
      community = create(:community)
      create(:theme, community: community)

      expect { community.destroy }.not_to change(Community, :count)
      expect(community.errors[:base]).to be_present
    end

    it 'テーマが存在しない場合はコミュニティを削除できる' do
      community = create(:community)

      expect { community.destroy }.to change(Community, :count).by(-1)
    end
  end
end
