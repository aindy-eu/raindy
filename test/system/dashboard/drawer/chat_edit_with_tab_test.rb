# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"

class ChatEditWithTabTest < ApplicationSystemTestCase
  include KeyboardNavigationHelper

  setup do
    @user = create(:user, :with_3_chats)
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end

  test "User edits chat name and submits with Tab key. Closes, reopens, and focuses on editChatLink" do
    @drawer.open
    @drawer.assert_drawer_visible

    second_chat = @user.chats.second
    second_chat_id = dom_id(second_chat)

    assert_selector "turbo-frame##{second_chat_id}", visible: true, wait: 5

    focus_element_with_tab("turbo-frame##{second_chat_id} [data-chats--chat-list-target='editChatLink']")
    find("turbo-frame##{second_chat_id} [data-chats--chat-list-target='editChatLink']").send_keys(:enter)

    assert_selector "form[role='form'][aria-label='#{I18n.t("chats.chat.form_edit_aria")}']", visible: true

    new_name = "Updated Chat Tab"

    within("turbo-frame##{second_chat_id}") do
      fill_in "chat[name]", with: new_name
      find("[data-chats--chat-edit-target='chatNameInput']").send_keys(:tab)

      assert_text new_name, wait: 5
      assert_selector "[data-chats--chat-list-target='editChatLink']", visible: true

      focused_frame_id = page.evaluate_script("document.activeElement.closest('turbo-frame')?.id")
      assert_equal second_chat_id, focused_frame_id
    end

    assert_equal new_name, Chat.find(second_chat.id).name

    focus_data = page.evaluate_script("sessionStorage.getItem('chatFocus')")
    parsed_focus = JSON.parse(focus_data)

    assert_equal second_chat_id, parsed_focus["frameId"]
    assert_equal "editChatLink", parsed_focus["target"]

    @drawer.close_by_escape
    @drawer.open
    @drawer.assert_drawer_visible

    assert has_selector?("##{second_chat_id} [data-chats--chat-list-target='editChatLink']:focus", wait: 5)
  end
end
