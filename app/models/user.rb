class User < ApplicationRecord
  attr_accessor :invite_key
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :themes, dependent: :destroy
  has_many :theme_votes, dependent: :destroy
  has_many :voted_themes, through: :theme_votes, source: :theme
  has_many :theme_comments, dependent: :destroy
  has_many :rsvps, dependent: :destroy
  has_many :rsvp_themes, through: :rsvps, source: :theme
end
