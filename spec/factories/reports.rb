FactoryBot.define do
  factory :report do
    association :reporter, factory: :user
    association :reportable, factory: :theme
    reason { "不適切なコンテンツです" }
    status { :pending }
  end
end
