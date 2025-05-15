# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"

class ChatCreateWithClickTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end

  test "User creates a chat in the drawer and sees it listed" do
    @drawer.open
    @drawer.assert_drawer_visible

    chat_name = "My System Chat"
    assert_selector "turbo-frame#chats_new", visible: true, wait: 5
    within "turbo-frame#chats_new" do
      fill_in "chat_chats-new-chat-name", with: chat_name
      find("button[aria-label='#{I18n.t("helpers.submit.create", model: Chat.model_name.human)}']").click
    end

    # Wait for the Turbo Stream to prepend the new chat to the list
    # Unfortunately the all("turbo-frame", wait: 5) - didn't work in this case
    # slow_down(1)
    within "div#chats" do
      assert_selector "turbo-frame", wait: 5  # This forces waiting for at least one frame.
      chat_elements = all("turbo-frame")
      assert chat_elements.any?, "Expected at least one turbo-frame in the chat list"
      assert_includes chat_elements.first.text, chat_name
    end
  end
end
