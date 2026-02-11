require 'rails_helper'

RSpec.describe Theme, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:community) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:theme_votes).dependent(:destroy) }
    it { is_expected.to have_many(:voters).through(:theme_votes).source(:user) }
    it { is_expected.to have_many(:theme_comments).dependent(:destroy) }
    it { is_expected.to have_many(:rsvps).dependent(:destroy) }
    it { is_expected.to have_many(:rsvp_users).through(:rsvps).source(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(100) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_length_of(:description).is_at_most(1000) }

    context 'when secondary_enabled is true' do
      subject { build(:theme, secondary_enabled: true) }
      it { is_expected.to validate_presence_of(:secondary_label) }
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:category).with_values(tech: 0, community: 1) }
    it { is_expected.to define_enum_for(:status).with_values(active: 0, archived: 1) }
  end

  describe 'scopes' do
    let!(:old_theme) { create(:theme, created_at: 2.days.ago, theme_votes_count: 5, status: :active) }
    let!(:new_theme) { create(:theme, created_at: 1.day.ago, theme_votes_count: 10, status: :active) }
    let!(:archived_theme) { create(:theme, status: :archived) }

    describe '.recent' do
      it 'returns themes ordered by created_at desc' do
        expect(Theme.recent.where(id: [old_theme.id, new_theme.id, archived_theme.id])).to eq([archived_theme, new_theme, old_theme])
      end
    end

    describe '.by_category' do
      let!(:tech_theme) { create(:theme, category: :tech) }
      let!(:community_theme) { create(:theme, category: :community) }

      it 'returns themes of specified category' do
        expect(Theme.by_category(:tech)).to include(tech_theme)
        expect(Theme.by_category(:tech)).not_to include(community_theme)
      end
    end

    describe '.popular' do
      it 'returns themes ordered by theme_votes_count desc' do
        expect(Theme.popular.first(2)).to eq([new_theme, old_theme])
      end
    end

    describe '.active_themes' do
      it 'returns only active themes' do
        expect(Theme.active_themes).to include(old_theme, new_theme)
        expect(Theme.active_themes).not_to include(archived_theme)
      end
    end

    describe '.archived_themes' do
      it 'returns only archived themes' do
        expect(Theme.archived_themes).to include(archived_theme)
        expect(Theme.archived_themes).not_to include(old_theme, new_theme)
      end
    end
  end
end
