require 'rails_helper'

RSpec.describe "Themes::Votes", type: :request do
  let(:user) { create(:user) }
  let(:theme) { create(:theme) }

  describe "POST /themes/:theme_id/vote" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        post theme_vote_path(theme)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in" do
      before { sign_in user }

      context "when user has not voted yet" do
        it "creates a new vote" do
          expect {
            post theme_vote_path(theme)
          }.to change(ThemeVote, :count).by(1)
        end

        it "increments theme votes count" do
          expect {
            post theme_vote_path(theme)
          }.to change { theme.reload.theme_votes_count }.by(1)
        end

        it "redirects to theme page with notice" do
          post theme_vote_path(theme)
          expect(response).to redirect_to(theme)
          expect(flash[:notice]).to eq("投票しました")
        end
      end

      context "when user has already voted" do
        before { create(:theme_vote, user: user, theme: theme) }

        it "does not create duplicate vote" do
          expect {
            post theme_vote_path(theme)
          }.not_to change(ThemeVote, :count)
        end

        it "redirects with already voted notice" do
          post theme_vote_path(theme)
          expect(response).to redirect_to(theme)
          expect(flash[:notice]).to eq("既に投票済みです")
        end
      end

      context "when concurrent vote attempts occur" do
        it "handles race condition gracefully" do
          create(:theme_vote, user: user, theme: theme)

          expect {
            post theme_vote_path(theme)
          }.not_to raise_error
        end
      end
    end
  end

  describe "DELETE /themes/:theme_id/vote" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        delete theme_vote_path(theme)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in" do
      before { sign_in user }

      context "when user has voted" do
        let!(:vote) { create(:theme_vote, user: user, theme: theme) }

        it "destroys the vote" do
          expect {
            delete theme_vote_path(theme)
          }.to change(ThemeVote, :count).by(-1)
        end

        it "decrements theme votes count" do
          expect {
            delete theme_vote_path(theme)
          }.to change { theme.reload.theme_votes_count }.by(-1)
        end

        it "redirects to theme page with notice" do
          delete theme_vote_path(theme)
          expect(response).to redirect_to(theme)
          expect(flash[:notice]).to eq("投票を取り消しました")
        end
      end

      context "when user has not voted" do
        it "does not raise error" do
          expect {
            delete theme_vote_path(theme)
          }.not_to change(ThemeVote, :count)
        end

        it "redirects with already cancelled notice" do
          delete theme_vote_path(theme)
          expect(response).to redirect_to(theme)
          expect(flash[:notice]).to eq("既に取り消し済みです")
        end
      end

      context "when vote was already deleted" do
        it "handles double deletion gracefully" do
          expect {
            delete theme_vote_path(theme)
            delete theme_vote_path(theme)
          }.not_to raise_error
        end
      end
    end
  end

  describe "vote toggle behavior" do
    before { sign_in user }

    it "allows user to vote, unvote, and revote" do
      # 投票
      post theme_vote_path(theme)
      expect(theme.reload.theme_votes_count).to eq(1)

      # 取消
      delete theme_vote_path(theme)
      expect(theme.reload.theme_votes_count).to eq(0)

      # 再投票
      post theme_vote_path(theme)
      expect(theme.reload.theme_votes_count).to eq(1)
    end

    it "maintains accurate count with multiple users" do
      user2 = create(:user)

      post theme_vote_path(theme)
      sign_in user2
      post theme_vote_path(theme)

      expect(theme.reload.theme_votes_count).to eq(2)

      delete theme_vote_path(theme)
      expect(theme.reload.theme_votes_count).to eq(1)
    end
  end
end
