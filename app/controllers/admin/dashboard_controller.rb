module Admin
  class DashboardController < BaseController
    def show
      @weekly_themes = Theme.group_by_week(:created_at, last: 12).count
      @weekly_rsvps  = Rsvp.group_by_week(:created_at, last: 12).count
    end
  end
end
