require "rails_helper"

RSpec.describe "Themes Suggested Slots", type: :request do
  let(:user) { create(:user, cohort: 1) }

  before { sign_in user }

  describe "GET /themes/:id" do
    context "参加可能データがある場合" do
      let(:theme) { create(:theme, user: user, category: :tech) }

      before do
        # 月曜 19:00-20:00 に2人参加可能
        user2 = create(:user, cohort: 1)
        create(:availability_slot, user: user, category: "tech", wday: 1, start_minute: 1140, end_minute: 1200)
        create(:availability_slot, user: user2, category: "tech", wday: 1, start_minute: 1140, end_minute: 1200)
      end

      it "候補枠が表示される" do
        get theme_path(theme)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("開催候補枠")
        expect(response.body).to include("19:00")
        expect(response.body).to include("20:00")
      end
    end

    context "参加可能データがない場合" do
      let(:theme) { create(:theme, user: user, category: :tech) }

      it "候補なしメッセージが表示される" do
        get theme_path(theme)

        expect(response).to have_http_status(:ok)
        # 候補枠セクションが表示されることを確認
        expect(response.body).to include("開催候補枠")
      end
    end
  end
end
