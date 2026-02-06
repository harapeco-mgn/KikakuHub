FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    nickname { "テストユーザー" }
    cohort { 1 }
  end
end
