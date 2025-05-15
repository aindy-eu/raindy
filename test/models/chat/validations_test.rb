# frozen_string_literal: true

require "test_helper"

# test/models/chat/validations_test.rb
class ChatValidationsTest < ActiveSupport::TestCase
  test "chat is valid with all required attributes" do
    chat = build(:chat, name: "Valid Chat")
    assert chat.valid?
  end

  test "chat name cannot be blank" do
    chat = build(:chat, name: "")
    assert_not chat.valid?
    # puts "chat.errors[:name]: #{chat.errors[:name]}"
    assert_includes chat.errors[:name], I18n.t("activerecord.errors.models.chat.attributes.name.blank")
  end

  test "chat name with only whitespace is invalid" do
    chat = build(:chat, name: "   ")
    assert_not chat.valid?
    assert_includes chat.errors[:name], I18n.t("activerecord.errors.models.chat.attributes.name.blank")
  end

  test "chat name has invalid length" do
    chat = build(:chat, name: "A" * 80) # Constant MAX_CHAT_NAME_LENGTH = 75
    assert_not chat.valid?
    count = Constants::MAX_CHAT_NAME_LENGTH
    assert_includes chat.errors[:name], I18n.t("errors.messages.too_long.other", count: count)
  end
end
