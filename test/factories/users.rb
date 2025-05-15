# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user.#{n}@example.com" }
    password { "12#34!password!43#21" }
    password_confirmation { password }

    trait :with_3_chats do
      after(:create) do |user|
        create_list(:chat, 3, user: user)
      end
    end

    # https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md#has_many-associations
    factory :user_with_chats do
      chats { [ association(:chat) ] }
    end

    # https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md#has_and_belongs_to_many-associations
  end
end
