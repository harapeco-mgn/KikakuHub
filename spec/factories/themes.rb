FactoryBot.define do
  factory :theme do
    association :community
    association :user
    category { :tech }
    sequence(:title) { |n| "テーマ#{n}" }
    description { "テーマの説明文" }

    trait :confirmed do
      status { :confirmed }
      converted_event_url { "https://connpass.com/event/12345/" }
    end

    trait :done do
      status { :done }
      converted_event_url { "https://connpass.com/event/12345/" }
    end

    trait :archived do
      status { :archived }
    end
  end
end
