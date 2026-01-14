FactoryBot.define do
  factory :rsvp do
    user { nil }
    theme { nil }
    status { 1 }
    secondary_interest { false }
  end
end
