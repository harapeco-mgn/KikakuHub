FactoryBot.define do
  factory :community do
    sequence(:name) { |n| "コミュニティ#{n}" }
  end
end
