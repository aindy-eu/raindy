# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"

class ChatListEditLinkFocusWithKeyboardTest < ApplicationSystemTestCase
  include KeyboardNavigationHelper

  setup do
    @user = create(:user, :with_3_chats)
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end

  test "User navigates to the second chat EDIT LINK with Tab key, closes drawer and opens it again" do
    @drawer.open
    @drawer.assert_drawer_visible

    # Wait for the last chat to appear
    second_chat_id = dom_id(@user.chats.second)
    find("turbo-frame##{second_chat_id}", visible: true, wait: 5)

    focus_element_with_tab("turbo-frame##{second_chat_id} [data-chats--chat-list-target='editChatLink']")

    @drawer.close_by_escape
    @drawer.open
    @drawer.assert_drawer_visible
    # Verify focus is restored to the edited chat's detail link
    assert has_selector?("##{second_chat_id} [data-chats--chat-list-target='editChatLink']:focus", wait: 5), "Focus should be restored to the edited chat's detail link"
  end
end
