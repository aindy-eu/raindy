# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"

class ChatUiTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, :with_3_chats)
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end

  test "User views the chat list in the drawer" do
    @drawer.open
    @drawer.assert_drawer_visible

    # Wait for the first chat to appear to ensure the list is loaded
    first_chat_id = dom_id(@user.chats.first)
    find("turbo-frame##{first_chat_id}", visible: true, wait: 5)

    # Check drawer title
    assert_selector "h2#drawer-title", text: I18n.t("chats.drawer.title")

    # Check new chat form is present
    assert_selector "turbo-frame#chats_new"

    # Check chat list container and items
    within "div#chats" do
      assert_equal @user.chats.count, all("turbo-frame").size
      @user.chats.each do |chat|
        chat_id = dom_id(chat)
        assert_selector "turbo-frame##{chat_id}", visible: true, wait: 5
        within("turbo-frame##{chat_id}") do
          assert_text chat.name
          assert_selector "[data-chats--chat-list-target='editChatLink']", visible: true
          assert_selector "[data-chats--chat-list-target='deleteChat']", visible: true
        end
      end
    end
  end
end
