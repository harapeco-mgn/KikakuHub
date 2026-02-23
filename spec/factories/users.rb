FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    nickname { "テストユーザー" }
    cohort { 1 }

    trait :admin do
      role { :admin }
    end

    trait :editor do
      role { :editor }
    end
  end
end
