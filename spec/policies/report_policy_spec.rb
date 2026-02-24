require 'rails_helper'

RSpec.describe ReportPolicy, type: :policy do
  let(:general_user) { create(:user) }
  let(:editor_user) { create(:user, :editor) }
  let(:admin_user) { create(:user, :admin) }
  let(:theme) { create(:theme) }
  let(:report) { build(:report, reporter: general_user, reportable: theme) }

  subject { described_class }

  permissions :create? do
    it { is_expected.to permit(general_user, report) }
    it { is_expected.to permit(editor_user, report) }
    it { is_expected.to permit(admin_user, report) }
    it { is_expected.not_to permit(nil, report) }
  end

  permissions :index? do
    it { is_expected.not_to permit(general_user, report) }
    it { is_expected.not_to permit(editor_user, report) }
    it { is_expected.to permit(admin_user, report) }
  end

  permissions :review? do
    it { is_expected.not_to permit(general_user, report) }
    it { is_expected.not_to permit(editor_user, report) }
    it { is_expected.to permit(admin_user, report) }
  end

  permissions :dismiss? do
    it { is_expected.not_to permit(general_user, report) }
    it { is_expected.not_to permit(editor_user, report) }
    it { is_expected.to permit(admin_user, report) }
  end
end
