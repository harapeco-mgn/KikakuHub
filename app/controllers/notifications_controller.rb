class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [ :read ]

  def index
    @notifications = current_user.notifications
                                 .includes(:actor, :notifiable)
                                 .recent
                                 .page(params[:page]).per(20)
  end

  def read
    @notification.mark_as_read!
    theme = @notification.target_theme
    if theme
      redirect_to theme_path(theme), status: :see_other
    else
      redirect_to notifications_path, status: :see_other
    end
  end

  def read_all
    current_user.notifications.unread.find_each(&:mark_as_read!)
    redirect_to notifications_path, notice: "すべての通知を既読にしました。", status: :see_other
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
