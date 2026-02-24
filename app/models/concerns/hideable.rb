module Hideable
  extend ActiveSupport::Concern

  included do
    scope :visible, -> { where(hidden_at: nil) }
    scope :hidden, -> { where.not(hidden_at: nil) }
  end

  def hidden?
    hidden_at.present?
  end

  def hide!
    update!(hidden_at: Time.current)
  end

  def unhide!
    update!(hidden_at: nil)
  end
end
