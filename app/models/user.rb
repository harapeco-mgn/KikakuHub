class User < ApplicationRecord
  attr_accessor :invite_key
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, presence: true, length: { maximum: 50 }
  validates :cohort, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  has_many :themes, dependent: :destroy
  has_many :theme_votes, dependent: :destroy
  has_many :voted_themes, through: :theme_votes, source: :theme
  has_many :theme_comments, dependent: :destroy
  has_many :rsvps, dependent: :destroy
  has_many :rsvp_themes, through: :rsvps, source: :theme
  has_many :availability_slots, dependent: :destroy

  def cohort_label
    cohort.to_i > 0 ? "#{cohort}期" : "未設定"
  end

  def self.cohort_options
    distinct.order(:cohort).pluck(:cohort).compact
  end
end
