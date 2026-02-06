require 'rails_helper'

RSpec.describe Rsvp, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:theme) }
  end

  describe 'validations' do
    describe 'uniqueness of user_id scoped to theme_id' do
      subject { create(:rsvp) }
      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:theme_id) }
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(attending: 0, not_attending: 1, undecided: 2) }
  end

  describe 'database constraints' do
    it 'enforces unique index on user_id and theme_id' do
      user = create(:user)
      theme = create(:theme)
      create(:rsvp, user: user, theme: theme)

      expect {
        create(:rsvp, user: user, theme: theme)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'default values' do
    it 'sets default status to undecided on create' do
      rsvp = build(:rsvp, status: nil)
      expect(rsvp.status).to be_nil
      rsvp.save
      expect(rsvp.status).to eq('undecided')
    end
  end
end
