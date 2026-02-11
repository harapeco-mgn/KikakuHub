class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern unless Rails.env.test?

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes unless Rails.env.test?

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: %i[nickname cohort])
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[nickname cohort])
  end

  def authorize_owner!(resource, redirect_path = root_path)
    return if resource.user == current_user

    redirect_to redirect_path, alert: "削除権限がありません。", status: :see_other
  end
end
