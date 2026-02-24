class Report < ApplicationRecord
  belongs_to :reporter, class_name: "User"
  belongs_to :reportable, polymorphic: true

  enum :status, { pending: 0, reviewed: 1, dismissed: 2 }

  validates :reason, presence: true, length: { maximum: 500 }
  validates :reporter_id, uniqueness: {
    scope: %i[reportable_type reportable_id],
    message: "はすでにこのコンテンツを通報済みです"
  }
end
