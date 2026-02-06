FactoryBot.define do
  factory :rsvp do
    association :user
    association :theme
    status { :undecided }
    secondary_interest { false }
  end
end
