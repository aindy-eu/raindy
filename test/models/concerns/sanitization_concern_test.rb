# frozen_string_literal: true

require "test_helper"

# test/models/chat/concerns/sanitization_concern_test.rb
class SanitizationConcernTest < ActiveSupport::TestCase
  test "sanitize_fields callback removes HTML tags" do
    chat = build(:chat, name: "<b>Bold Name</b>")
    # The sanitize_columns works with tags: [] so all tags are removed
    chat.valid?
    assert_equal "Bold Name", chat.name
  end

  test "sanitize_fields removes HTML attributes" do
    chat = build(:chat, name: '<a href="example.com">Link</a>')
    # The sanitize_columns works with attributes: [] so all attributes are removed
    chat.valid?
    assert_equal "Link", chat.name
  end

  test "sanitize_fields against XSS attacs" do
    # Different flavor of creating the chat  ;)
    chat = Chat.new(name: "<script>alert('XSS')</script>", user:  build(:user))
    # false because of `'` in our chat strict_validation
    chat.valid?
    # We only check the functionality
    assert_equal "alert('XSS')", chat.name
  end

  test "does not affect non-string fields" do
    chat = Chat.new(name: "Valid Name", user: create(:user), created_at: Time.current)
    chat.save!
    assert_not_nil chat.created_at
  end

  test "sanitize_fields does not affect empty fields" do
    # A lttile bit academic
    chat = build(:chat, name: "")
    # This is false and actually is handled in the models/chat/validations_test ;)
    chat.valid?
    # As I sad - academic
    assert_equal "", chat.name
  end

  test "sanitize_fields handles strings with newlines and tabs" do
    chat = build(:chat, name: "Name with\nnewline and\ttab")
    chat.valid?
    assert_equal "Name with newline and tab", chat.name
  end
end
