require 'rails_helper'

RSpec.describe ThemePolicy, type: :policy do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:editor_user) { create(:user, :editor) }
  let(:admin_user) { create(:user, :admin) }
  let(:theme) { create(:theme, user: owner) }

  subject { described_class }

  permissions :show? do
    it { is_expected.to permit(owner, theme) }
    it { is_expected.to permit(other_user, theme) }
    it { is_expected.to permit(editor_user, theme) }
    it { is_expected.to permit(admin_user, theme) }
  end

  permissions :create? do
    it { is_expected.to permit(owner, theme) }
    it { is_expected.to permit(other_user, theme) }
    it { is_expected.to permit(editor_user, theme) }
    it { is_expected.to permit(admin_user, theme) }
  end

  permissions :update? do
    it { is_expected.to permit(owner, theme) }
    it { is_expected.not_to permit(other_user, theme) }
    it { is_expected.to permit(editor_user, theme) }
    it { is_expected.to permit(admin_user, theme) }
  end

  permissions :destroy? do
    it { is_expected.to permit(owner, theme) }
    it { is_expected.not_to permit(other_user, theme) }
    it { is_expected.to permit(editor_user, theme) }
    it { is_expected.to permit(admin_user, theme) }
  end

  permissions :transition? do
    it { is_expected.to permit(owner, theme) }
    it { is_expected.not_to permit(other_user, theme) }
    it { is_expected.not_to permit(editor_user, theme) }
    it { is_expected.to permit(admin_user, theme) }
  end

  permissions :archived? do
    it { is_expected.to permit(owner, theme) }
    it { is_expected.to permit(other_user, theme) }
    it { is_expected.to permit(editor_user, theme) }
    it { is_expected.to permit(admin_user, theme) }
  end
end
