# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Should contain high-level or miscellaneous tests for the User model
  # that aren’t covered in more specific files.
  test "should have a valid factory" do
    user = build(:user)
    assert user.valid?
  end
end
