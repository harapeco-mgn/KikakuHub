require 'rails_helper'

RSpec.describe AvailabilitySlot, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:category).with_values(tech: 0, community: 1) }
  end

  describe 'validations' do
    subject { build(:availability_slot) }

    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:wday) }
    it { is_expected.to validate_presence_of(:start_minute) }
    it { is_expected.to validate_presence_of(:end_minute) }
  end
end
