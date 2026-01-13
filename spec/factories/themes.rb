FactoryBot.define do
  factory :theme do
    community { nil }
    user { nil }
    category { 1 }
    title { "MyString" }
    description { "MyText" }
  end
end
