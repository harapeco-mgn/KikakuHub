FactoryBot.define do
  factory :theme do
    association :community
    association :user
    category { :tech }
    sequence(:title) { |n| "テーマ#{n}" }
    description { "テーマの説明文" }
  end
end
