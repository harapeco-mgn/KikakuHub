class ThemeComment < ApplicationRecord
  belongs_to :user
  belongs_to :theme

  validates :body, presence: true, length: { maximum: 255 }
end
