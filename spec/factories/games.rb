FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }
    description { 'A fun and engaging game for all players' }
    min_participants { 2 }
    max_participants { 10 }
    
    trait :with_min_players do
      min_participants { 1 }
      max_participants { 2 }
    end
    
    trait :with_many_players do
      min_participants { 5 }
      max_participants { 20 }
    end
    
    trait :started do
      started_at { 1.hour.ago }
    end
    
    trait :completed do
      started_at { 1.day.ago }
      completed_at { 1.hour.ago }
    end
  end
end
