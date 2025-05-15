# frozen_string_literal: true

require "test_helper"

# test/models/user/devise_test.rb
class UserAuthTest < ActiveSupport::TestCase
  def setup
    @user = build(:user, password: "password123")
  end

  test "should authenticate with valid password" do
    @user.save!
    assert @user.authenticate("password123"), "Authenticated with an correct password"
  end

  test "should not authenticate with invalid password" do
    @user.save!
    assert_not @user.authenticate("wrongpassword"), "Authenticated with an incorrect password"
  end
end
