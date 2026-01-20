FactoryBot.define do
  factory :availability_slot do
    user { nil }
    category { 1 }
    wday { 1 }
    start_minute { 1 }
    end_minute { 1 }
  end
end
