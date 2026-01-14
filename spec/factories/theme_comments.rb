FactoryBot.define do
  factory :theme_comment do
    user { nil }
    theme { nil }
    body { "MyText" }
  end
end
