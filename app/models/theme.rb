class Theme < ApplicationRecord
  belongs_to :community
  belongs_to :user

  enum :category, { tech: 0, community: 1 }

  validates :category, presence: true
  validates :title, presence: true
  validates :description, presence: true

  has_many :theme_votes, dependent: :destroy
  has_many :voters, through: :theme_votes, source: :user
  has_many :theme_comments, dependent: :destroy
end
