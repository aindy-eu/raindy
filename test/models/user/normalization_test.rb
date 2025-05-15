# frozen_string_literal: true

require "test_helper"

# test/models/user/normalization_test.rb
class UserNormalizationTest < ActiveSupport::TestCase
  def setup
    @user = build(:user, email_address: "USER@Example.COM")
  end

  test "should downcase email before saving" do
    @user.save!
    assert_equal "user@example.com", @user.email_address
  end

  test "should strip whitespace from email before saving" do
    @user.email_address = "   user@example.com   "
    @user.save!
    assert_equal "user@example.com", @user.email_address
  end

  test "should normalize email with complex case" do
    @user.email_address = "  USER+alias@ExAmple.COM  "
    @user.save!
    assert_equal "user+alias@example.com", @user.email_address
  end
end
