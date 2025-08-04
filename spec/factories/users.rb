FactoryBot.define do
  factory :user do
    username { Faker::Internet.unique.username(specifier: 3..30) }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_short_username do
      username { "ab" }
    end

    trait :with_long_username do
      username { "a" * 31 }
    end

    trait :with_invalid_email do
      email { "invalid-email" }
    end

    trait :with_short_password do
      password { "12345" }
      password_confirmation { "12345" }
    end
  end
end
