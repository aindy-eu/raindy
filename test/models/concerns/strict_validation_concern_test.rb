# frozen_string_literal: true

require "test_helper"

# test/models/chat/concerns/strict_validation_concern_test.rb
class StrictValidationConcernTest < ActiveSupport::TestCase
  # Testing chat name
  test "name allows only valid characters" do
    chat = build(:chat, name: "Valid Name ? & - _ + and äüß")
    assert chat.valid?, "Expected the chat name to be valid"
  end

  test "name does not allow invalid characters e.g. # and %" do
    chat = build(:chat, name: "Invalid Name with hashtag # and %")
    assert_not chat.valid?
    assert_includes chat.errors[:name], I18n.t("activerecord.errors.models.chat.attributes.name.invalid_characters")
  end
end
