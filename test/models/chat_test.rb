# frozen_string_literal: true

require "test_helper"

class ChatTest < ActiveSupport::TestCase
  # Should contain high-level or miscellaneous tests for the Chat model
  # that aren’t covered in more specific files.
  test "should have a valid factory" do
    chat = build(:chat)
    # When you place binding.irb in your code, execution will pause at that point,
    # and you’ll drop into an interactive IRB console in the terminal.
    # binding.irb
    assert chat.valid?
  end
end
