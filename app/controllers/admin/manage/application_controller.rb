module Admin
  module Manage
    class ApplicationController < ::Administrate::ApplicationController
      before_action :authenticate_user!
      before_action :require_admin!

      private

      def require_admin!
        return if current_user&.admin?

        redirect_to root_path, alert: "管理者のみアクセスできます。", status: :see_other
      end
    end
  end
end
