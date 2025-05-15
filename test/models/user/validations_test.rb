# frozen_string_literal: true

# test/models/user/validations_test.rb
require "test_helper"

class UserValidationsTest < ActiveSupport::TestCase
  def setup
    @valid_user = build(:user)
    @invalid_email_user = build(:user, email_address: "invalid-email")
  end

  test "should be valid with valid attributes" do
    assert @valid_user.valid?
  end

  test "should require email_address" do
    @valid_user.email_address = ""
    assert_not @valid_user.valid?, "Expected user to be invalid without an email_address"

    assert_equal 2, @valid_user.errors[:email_address].count, "Expected exactly two errors for email_address"
    assert_includes @valid_user.errors[:email_address], I18n.t("errors.messages.blank")
    assert_includes @valid_user.errors[:email_address], I18n.t("errors.messages.invalid_email")
  end

  test "should validate email_address format" do
    assert_not @invalid_email_user.valid?, "Expected user to be invalid with invalid email_address format"
    assert_includes @invalid_email_user.errors[:email_address], I18n.t("errors.messages.invalid_email")
  end

  test "should validate email_address uniqueness" do
    @valid_user.save!
    duplicate_user = build(:user, email_address: @valid_user.email_address)
    assert_not duplicate_user.valid?, "Expected user to be invalid with duplicate email_address"
    assert_includes duplicate_user.errors[:email_address], I18n.t("errors.messages.taken")
  end

  test "should invalidate incorrect email addresses" do
    invalid_emails = [
      "user@domain",
      "user@domain.c",
      ".dot..dot.@example.org"
    ]

    invalid_emails.each do |invalid_email|
      user = build(:user, email_address: invalid_email)
      # puts "Testing email: #{invalid_email}, Regex match: #{User::EMAIL_VALIDATION_REGEX.match?(invalid_email)}"
      assert_not user.valid?, "Expected user to be invalid with email_address: #{invalid_email}"
      assert_includes user.errors[:email_address], I18n.t("errors.messages.invalid_email")
    end
  end

  test "should not save user without a password" do
    user = build(:user, password: nil)
    assert_not user.valid?
    assert_includes user.errors[:password], I18n.t("errors.messages.blank")
  end
end
