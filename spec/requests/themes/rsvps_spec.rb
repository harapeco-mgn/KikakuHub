require 'rails_helper'

RSpec.describe "Themes::Rsvps", type: :request do
  let(:user) { create(:user) }
  let(:theme) { create(:theme, secondary_enabled: true, secondary_label: "第2希望") }

  describe "PATCH /themes/:theme_id/rsvp" do
    before { sign_in user }

    # Turbo Stream形式でリクエストを送るヘルパー
    def patch_rsvp(params)
      patch theme_rsvp_path(theme), params: params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    context "when updating status" do
      it "creates rsvp and updates status" do
        expect {
          patch_rsvp({ rsvp: { status: :attending } })
        }.to change(Rsvp, :count).by(1)

        expect(Rsvp.last.status).to eq("attending")
      end

      it "updates existing rsvp status" do
        rsvp = create(:rsvp, user: user, theme: theme, status: :undecided)

        patch_rsvp({ rsvp: { status: :attending } })

        expect(rsvp.reload.status).to eq("attending")
      end
    end

    context "when updating secondary_interest" do
      context "with attending status" do
        let!(:rsvp) { create(:rsvp, user: user, theme: theme, status: :attending, secondary_interest: false) }

        it "allows secondary_interest update" do
          patch_rsvp({ rsvp: { secondary_interest: true } })

          expect(rsvp.reload.secondary_interest).to be true
        end

        it "returns success response" do
          patch_rsvp({ rsvp: { secondary_interest: true } })

          expect(response).to have_http_status(:ok)
        end
      end

      context "without attending status (undecided)" do
        let!(:rsvp) { create(:rsvp, user: user, theme: theme, status: :undecided, secondary_interest: false) }

        it "rejects secondary_interest update" do
          patch_rsvp({ rsvp: { secondary_interest: true } })

          expect(rsvp.reload.secondary_interest).to be false
        end

        it "returns unprocessable_entity" do
          patch_rsvp({ rsvp: { secondary_interest: true } })

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "shows error message" do
          patch_rsvp({ rsvp: { secondary_interest: true } })

          expect(flash[:alert]).to eq("参加表明が必要です。")
        end
      end

      context "without attending status (not_attending)" do
        let!(:rsvp) { create(:rsvp, user: user, theme: theme, status: :not_attending, secondary_interest: false) }

        it "rejects secondary_interest update" do
          patch_rsvp({ rsvp: { secondary_interest: true } })

          expect(rsvp.reload.secondary_interest).to be false
        end
      end

      context "when rsvp does not exist yet (new record)" do
        it "rejects secondary_interest update" do
          expect {
            patch_rsvp({ rsvp: { secondary_interest: true } })
          }.not_to change(Rsvp, :count)
        end

        it "returns unprocessable_entity" do
          patch_rsvp({ rsvp: { secondary_interest: true } })

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when updating both status and secondary_interest" do
      it "allows updating both when status is attending" do
        rsvp = create(:rsvp, user: user, theme: theme, status: :undecided, secondary_interest: false)

        patch_rsvp({ rsvp: { status: :attending, secondary_interest: true } })

        rsvp.reload
        expect(rsvp.status).to eq("attending")
        expect(rsvp.secondary_interest).to be true
      end

      it "rejects secondary_interest when status is not attending" do
        rsvp = create(:rsvp, user: user, theme: theme, status: :attending, secondary_interest: true)

        patch_rsvp({ rsvp: { status: :undecided, secondary_interest: true } })

        rsvp.reload
        expect(rsvp.status).to eq("undecided")
        expect(rsvp.secondary_interest).to be true # 変更されない
      end
    end

    context "when changing from attending to not_attending" do
      let!(:rsvp) { create(:rsvp, user: user, theme: theme, status: :attending, secondary_interest: true) }

      it "allows status change but keeps secondary_interest unchanged" do
        patch_rsvp({ rsvp: { status: :not_attending } })

        rsvp.reload
        expect(rsvp.status).to eq("not_attending")
        expect(rsvp.secondary_interest).to be true # そのまま
      end
    end
  end
end
