class Theme < ApplicationRecord
  belongs_to :community
  belongs_to :user

  enum :category, { tech: 0, community: 1 }

  validates :category, presence: true
  validates :title, presence: true
  validates :description, presence: true
end
