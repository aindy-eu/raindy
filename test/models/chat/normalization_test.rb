# frozen_string_literal: true

require "test_helper"

# test/models/chat/normalization_test.rb
class ChatNormalizationTest < ActiveSupport::TestCase
  test "should strip whitespace from name before saving" do
    # In this test we build the chat and since our factory chat
    # belongs to a user, we do not need to create a user
    chat = build(:chat, name: "  Chat Name with whitespaces  ")
    chat.save!
    assert_equal "Chat Name with whitespaces", chat.name
  end

  test "chat name is stripped of leading and trailing whitespace" do
    # In this test we create a user for better readability
    user = create(:user)

    # v1: Test pre-save transformations in memory
    chat = Chat.new(name: "   Example Chat   ", user: user)
    chat.valid?
    assert_equal "Example Chat", chat.name

    # v2: Test full lifecycle including persistence and associations
    chat = user.chats.create!(name: "    Test Chat    ")
    assert_equal "Test Chat", chat.name
    assert_equal user.id, chat.user_id
  end

  test "normalizes name if name is updated" do
    chat = create(:chat, name: "  Created Chat  ")
    assert_equal "Created Chat", chat.name

    # Test update
    chat.update!(name: "   Updated Chat   ")
    assert_equal "Updated Chat", chat.name
  end
end
