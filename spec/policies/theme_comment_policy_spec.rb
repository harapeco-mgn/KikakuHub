require 'rails_helper'

RSpec.describe ThemeCommentPolicy, type: :policy do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:editor_user) { create(:user, :editor) }
  let(:admin_user) { create(:user, :admin) }
  let(:theme) { create(:theme, user: owner) }
  let(:comment) { create(:theme_comment, user: owner, theme: theme) }

  subject { described_class }

  permissions :create? do
    it { is_expected.to permit(owner, comment) }
    it { is_expected.to permit(other_user, comment) }
    it { is_expected.to permit(editor_user, comment) }
    it { is_expected.to permit(admin_user, comment) }
  end

  permissions :destroy? do
    it { is_expected.to permit(owner, comment) }
    it { is_expected.not_to permit(other_user, comment) }
    it { is_expected.to permit(editor_user, comment) }
    it { is_expected.to permit(admin_user, comment) }
  end
end
