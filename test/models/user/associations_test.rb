# frozen_string_literal: true

require "test_helper"

# test/models/user/associations_test.rb
class UserAssociationsTest < ActiveSupport::TestCase
  def setup
    @user = build(:user)
  end

  test "should not respond to company association" do
    assert_not_respond_to @user, :company, "User should not have a company association"
  end

  # Add tests for any other unexpected associations
  test "should not respond to posts association" do
    assert_not_respond_to @user, :posts, "User should not have a posts association"
  end

  test "user has many chats" do
    assert_respond_to @user, :chats, "User should have chats association"
  end

  test "user's chat is destroyed when the user is destroyed" do
    user = create(:user)
    # Creates an associated chat with our correct model assoc
    user.chats.create!(name: "Test Chat")

    # Assert that destroying the user also destroys their chats
    assert_difference "Chat.count", -1 do
      user.destroy
    end
  end

  test "user has many chats with dependent destroy" do
    # Different creation of chats with a 'trait' (factory)
    user = create(:user, :with_3_chats)
    assert_equal 3, user.chats.count

    # Assert that destroying the user also destroys their chats
    assert_difference "Chat.count", -3 do
      user.destroy
    end
  end
end
