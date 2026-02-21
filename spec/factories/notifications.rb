FactoryBot.define do
  factory :notification do
    association :user
    association :actor, factory: :user
    association :notifiable, factory: :theme
    action_type { :theme_confirmed }
    read_at { nil }

    trait :commented do
      association :notifiable, factory: :theme_comment
      action_type { :commented }
    end

    trait :rsvp_attending do
      association :notifiable, factory: :rsvp
      action_type { :rsvp_attending }
    end

    trait :read do
      read_at { 1.hour.ago }
    end
  end
end
