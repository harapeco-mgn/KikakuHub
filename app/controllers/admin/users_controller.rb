module Admin
  class UsersController < BaseController
    def index
      @users = User.left_joins(:themes)
                   .select("users.*, COUNT(themes.id) AS themes_count")
                   .group("users.id")
                   .order(created_at: :desc)
                   .page(params[:page]).per(30)
    end

    def show
      @user = User.find(params[:id])
      @themes = @user.themes.order(created_at: :desc)
    end

    def update_role
      @user = User.find(params[:id])
      if @user.update(role: params[:role])
        redirect_to admin_user_path(@user), notice: "ロールを更新しました。"
      else
        redirect_to admin_user_path(@user), alert: "ロールの更新に失敗しました。"
      end
    end
  end
end
