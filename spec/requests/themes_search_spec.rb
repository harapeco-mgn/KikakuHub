require 'rails_helper'

RSpec.describe "Themes Search", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /themes with search parameters" do
    let!(:tech_theme) { create(:theme, title: "Rails勉強会", description: "Railsを学ぶ", category: :tech, status: :active) }
    let!(:community_theme) { create(:theme, title: "コミュニティイベント", description: "交流会", category: :community, status: :active) }
    let!(:archived_theme) { create(:theme, title: "過去のイベント", description: "Rails", category: :tech, status: :archived) }

    context "without search parameters" do
      it "displays all active themes" do
        get themes_path
        expect(response.body).to include(tech_theme.title)
        expect(response.body).to include(community_theme.title)
        expect(response.body).not_to include(archived_theme.title)
      end
    end

    context "with keyword parameter" do
      it "displays themes matching keyword in title" do
        get themes_path, params: { keyword: "Rails" }
        expect(response.body).to include(tech_theme.title)
        expect(response.body).not_to include(community_theme.title)
      end

      it "displays themes matching keyword in description" do
        get themes_path, params: { keyword: "交流" }
        expect(response.body).to include(community_theme.title)
        expect(response.body).not_to include(tech_theme.title)
      end

      it "is case insensitive" do
        get themes_path, params: { keyword: "rails" }
        expect(response.body).to include(tech_theme.title)
      end
    end

    context "with category parameter" do
      it "displays only themes of specified category" do
        get themes_path, params: { category: "tech" }
        expect(response.body).to include(tech_theme.title)
        expect(response.body).not_to include(community_theme.title)
      end
    end

    context "with both keyword and category parameters" do
      it "displays themes matching both conditions" do
        get themes_path, params: { keyword: "Rails", category: "tech" }
        expect(response.body).to include(tech_theme.title)
        expect(response.body).not_to include(community_theme.title)
      end
    end
  end
end
