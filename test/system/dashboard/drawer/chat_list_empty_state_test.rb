# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"

class ChatListEmptyStateTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, :with_3_chats)
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end

  test "User sees no chats message when none exist" do
    # Sign in a user without chats
    user_without_chats = create(:user)
    sign_in(user_without_chats)
    @drawer.open
    @drawer.assert_drawer_visible
    # The drawer should display the 'No chats' hint
    assert_selector "p#no_chats_hint", text: I18n.t("chats.no_chats"), wait: 5

    within("turbo-frame#chats_index") do
      assert_equal 0, all("turbo-frame[id^='chat_']").count, "No chat items should be present"
    end
  end
end
