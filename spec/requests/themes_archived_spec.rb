require 'rails_helper'

RSpec.describe "Themes Archived", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /themes/archived" do
    let!(:active_theme) { create(:theme, status: :active) }
    let!(:archived_theme) { create(:theme, status: :archived) }

    it "returns http success" do
      get archived_themes_path
      expect(response).to have_http_status(:success)
    end

    it "displays only archived themes" do
      get archived_themes_path
      expect(response.body).to include(archived_theme.title)
      expect(response.body).not_to include(active_theme.title)
    end
  end
end
