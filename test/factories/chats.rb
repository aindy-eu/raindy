# frozen_string_literal: true

FactoryBot.define do
  factory :chat do
    # Generates a unique chat name for each chat instance
    sequence(:name) { |n| "Example Chat #{n}" }
    user
  end
end
