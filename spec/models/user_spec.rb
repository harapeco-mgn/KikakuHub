require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:themes).dependent(:destroy) }
    it { is_expected.to have_many(:theme_votes).dependent(:destroy) }
    it { is_expected.to have_many(:voted_themes).through(:theme_votes).source(:theme) }
    it { is_expected.to have_many(:theme_comments).dependent(:destroy) }
    it { is_expected.to have_many(:rsvps).dependent(:destroy) }
    it { is_expected.to have_many(:rsvp_themes).through(:rsvps).source(:theme) }
    it { is_expected.to have_many(:availability_slots).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:nickname) }
    it { is_expected.to validate_length_of(:nickname).is_at_most(50) }
    it { is_expected.to validate_numericality_of(:cohort).only_integer.is_greater_than(0).allow_nil }
  end

  describe '#cohort_label' do
    it 'returns formatted cohort when cohort is set' do
      user = build(:user, cohort: 10)
      expect(user.cohort_label).to eq("10期")
    end

    it 'returns "未設定" when cohort is 0' do
      user = build(:user, cohort: 0)
      expect(user.cohort_label).to eq("未設定")
    end

    it 'returns "未設定" when cohort is nil' do
      user = build(:user, cohort: nil)
      expect(user.cohort_label).to eq("未設定")
    end
  end

  describe '.cohort_options' do
    it 'returns distinct cohorts in ascending order' do
      create(:user, cohort: 10)
      create(:user, cohort: 5)
      create(:user, cohort: 10)

      expect(User.cohort_options).to include(5, 10)
      expect(User.cohort_options.uniq).to eq(User.cohort_options)
      expect(User.cohort_options).to eq(User.cohort_options.sort)
    end
  end
end
