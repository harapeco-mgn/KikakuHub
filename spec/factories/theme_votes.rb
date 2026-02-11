FactoryBot.define do
  factory :theme_vote do
    association :user
    association :theme
  end
end
