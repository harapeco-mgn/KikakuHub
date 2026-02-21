require 'rails_helper'

RSpec.describe "Themes Sort", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /themes with sort parameter" do
    let!(:old_theme)    { create(:theme, title: "古いテーマ", created_at: 3.days.ago, theme_votes_count: 5,  hosting_ease_score_cache: 20, status: :considering) }
    let!(:new_theme)    { create(:theme, title: "新しいテーマ", created_at: 1.day.ago,  theme_votes_count: 2,  hosting_ease_score_cache: 50, status: :considering) }
    let!(:popular_theme) { create(:theme, title: "人気テーマ",  created_at: 2.days.ago, theme_votes_count: 10, hosting_ease_score_cache: 80, status: :considering) }

    context "sort=recent（デフォルト）" do
      it "新着順（created_at降順）で表示される" do
        get themes_path, params: { sort: "recent" }
        expect(response).to have_http_status(:ok)
        body = response.body
        expect(body.index(new_theme.title)).to be < body.index(old_theme.title)
      end
    end

    context "sort パラメータなし" do
      it "新着順で表示される（デフォルト動作）" do
        get themes_path
        expect(response).to have_http_status(:ok)
        body = response.body
        expect(body.index(new_theme.title)).to be < body.index(old_theme.title)
      end
    end

    context "sort=popular" do
      it "投票数降順で表示される" do
        get themes_path, params: { sort: "popular" }
        expect(response).to have_http_status(:ok)
        body = response.body
        expect(body.index(popular_theme.title)).to be < body.index(old_theme.title)
      end
    end

    context "sort=hosting_ease" do
      it "開催しやすさスコア降順で表示される" do
        get themes_path, params: { sort: "hosting_ease" }
        expect(response).to have_http_status(:ok)
        body = response.body
        expect(body.index(popular_theme.title)).to be < body.index(old_theme.title)
      end
    end

    context "無効なsortパラメータ" do
      it "新着順にフォールバックする" do
        get themes_path, params: { sort: "invalid_sort" }
        expect(response).to have_http_status(:ok)
        body = response.body
        expect(body.index(new_theme.title)).to be < body.index(old_theme.title)
      end
    end

    context "キーワード検索とソートの組み合わせ" do
      it "検索結果がソート順で表示される" do
        get themes_path, params: { keyword: "テーマ", sort: "popular" }
        expect(response).to have_http_status(:ok)
        body = response.body
        expect(body).to include(popular_theme.title)
        expect(body.index(popular_theme.title)).to be < body.index(old_theme.title)
      end
    end
  end
end
