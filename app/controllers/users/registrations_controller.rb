class Users::RegistrationsController < Devise::RegistrationsController
  def create
    if Rails.configuration.x.invite_key_required
    # フォームから来た合言葉（DBに保存しない）
    input_key = params.dig(:user, :invite_key).to_s

    # 環境変数（未設定なら空文字になる）
    env_key = ENV.fetch("INVITE_KEY", "").to_s

    # 不一致、または環境変数未設定なら弾く（安全側）
    if env_key.blank? || input_key != env_key
      build_resource(sign_up_params) # 入力済み値（email等）を保持してフォーム再表示
      resource.errors.add(:invite_key, "が正しくありません")
      clean_up_passwords(resource)
      set_minimum_password_length
      render :new, status: :unprocessable_entity
      return
    end
  end

    # OKならDeviseの通常フローへ
    super
  end
end
