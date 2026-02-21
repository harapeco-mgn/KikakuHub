module NotificationsHelper
  def notification_icon(notification)
    case notification.action_type
    when "theme_confirmed" then "check_circle"
    when "commented"       then "chat_bubble_outline"
    when "rsvp_attending"  then "how_to_reg"
    end
  end

  def notification_icon_bg(notification)
    case notification.action_type
    when "theme_confirmed" then "bg-success/10"
    when "commented"       then "bg-info/10"
    when "rsvp_attending"  then "bg-secondary/10"
    end
  end

  def notification_icon_color(notification)
    case notification.action_type
    when "theme_confirmed" then "text-success"
    when "commented"       then "text-info"
    when "rsvp_attending"  then "text-secondary"
    end
  end
end
