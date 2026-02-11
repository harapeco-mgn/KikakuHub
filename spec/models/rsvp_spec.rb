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

  describe 'secondary_interest auto-clearing' do
    let(:user) { create(:user) }
    let(:theme) { create(:theme) }

    context 'when changing from attending to not_attending' do
      it 'clears secondary_interest' do
        rsvp = create(:rsvp, user: user, theme: theme, status: :attending, secondary_interest: true)

        rsvp.update(status: :not_attending)

        expect(rsvp.reload.secondary_interest).to be false
      end
    end

    context 'when changing from attending to undecided' do
      it 'clears secondary_interest' do
        rsvp = create(:rsvp, user: user, theme: theme, status: :attending, secondary_interest: true)

        rsvp.update(status: :undecided)

        expect(rsvp.reload.secondary_interest).to be false
      end
    end

    context 'when staying on attending' do
      it 'keeps secondary_interest' do
        rsvp = create(:rsvp, user: user, theme: theme, status: :attending, secondary_interest: true)

        rsvp.update(status: :attending)

        expect(rsvp.reload.secondary_interest).to be true
      end
    end

    context 'when creating with non-attending status' do
      it 'forces secondary_interest to false' do
        rsvp = create(:rsvp, user: user, theme: theme, status: :undecided, secondary_interest: true)

        expect(rsvp.reload.secondary_interest).to be false
      end
    end

    context 'when updating other attributes on non-attending status' do
      it 'clears secondary_interest if it was true' do
        rsvp = create(:rsvp, user: user, theme: theme, status: :undecided, secondary_interest: false)

        # 直接DBを変更して secondary_interest を true にする（不整合状態を作る）
        ActiveRecord::Base.connection.execute(
          "UPDATE rsvps SET secondary_interest = true WHERE id = #{rsvp.id}"
        )

        # 他の属性を更新すると、secondary_interest が自動的に false に戻る
        rsvp.reload
        expect(rsvp.secondary_interest).to be true # 確認

        rsvp.update(status: :undecided) # 同じstatusで更新
        expect(rsvp.reload.secondary_interest).to be false
      end
    end
  end
end
