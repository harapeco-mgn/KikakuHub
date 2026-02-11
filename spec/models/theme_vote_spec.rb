require 'rails_helper'

RSpec.describe ThemeVote, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:theme).counter_cache(true) }
  end

  describe 'validations' do
    subject { build(:theme_vote) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:theme_id) }
  end

  describe 'database constraints' do
    let(:user) { create(:user) }
    let(:theme) { create(:theme) }

    it 'has unique index on user_id and theme_id' do
      create(:theme_vote, user: user, theme: theme)

      # Directly insert bypassing ActiveRecord validations to test DB constraint
      expect {
        ActiveRecord::Base.connection.execute(
          "INSERT INTO theme_votes (user_id, theme_id, created_at, updated_at)
           VALUES (#{user.id}, #{theme.id}, NOW(), NOW())"
        )
      }.to raise_error(ActiveRecord::StatementInvalid, /duplicate key value violates unique constraint/)
    end
  end

  describe 'counter_cache' do
    let(:theme) { create(:theme) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    it 'increments theme_votes_count when created' do
      expect {
        create(:theme_vote, theme: theme, user: user1)
      }.to change { theme.reload.theme_votes_count }.by(1)
    end

    it 'decrements theme_votes_count when destroyed' do
      vote = create(:theme_vote, theme: theme, user: user1)

      expect {
        vote.destroy
      }.to change { theme.reload.theme_votes_count }.by(-1)
    end

    it 'accurately counts multiple votes' do
      create(:theme_vote, theme: theme, user: user1)
      create(:theme_vote, theme: theme, user: user2)

      expect(theme.reload.theme_votes_count).to eq(2)
    end
  end
end
