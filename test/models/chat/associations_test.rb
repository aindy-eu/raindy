# frozen_string_literal: true

require "test_helper"

# test/models/chat/associations_test.rb
class ChatAssociationsTest < ActiveSupport::TestCase
  test "chat belongs to a user" do
    chat = Chat.new
    assert_respond_to chat, :user
  end

  test "chat requires a user with Chat.new" do
    chat = Chat.new(name: "Test Chat")
    assert_not chat.valid?
    assert_includes chat.errors[:user], I18n.t("errors.messages.required")
  end

  test "chat must have a user build chat" do
    chat = build(:chat, user: nil)
    assert_not chat.valid?
    assert_includes chat.errors[:user], I18n.t("errors.messages.required")
  end
end
