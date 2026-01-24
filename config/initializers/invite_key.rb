Rails.application.config.x.invite_key_required =
  ActiveModel::Type::Boolean.new.cast(ENV.fetch("INVITE_KEY_REQUIRED", "false"))