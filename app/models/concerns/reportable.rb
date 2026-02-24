module Reportable
  extend ActiveSupport::Concern

  included do
    has_many :reports, as: :reportable, dependent: :destroy
  end

  def reported_by?(user)
    reports.exists?(reporter: user)
  end
end
