# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"

class ChatEditWithEscapeTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, :with_3_chats)
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end

  test "User edits a chat in the drawer, hits escape to cancel, and sees original chat restored" do
    @drawer.open
    @drawer.assert_drawer_visible

    first_chat = @user.chats.first
    original_name = first_chat.name
    chat_frame_id = dom_id(first_chat)

    assert_selector "turbo-frame##{chat_frame_id}", visible: true, wait: 5

    within("turbo-frame##{chat_frame_id}") do
      click_on I18n.t("helpers.button.rename")

      assert_selector "form[role='form'][aria-label='#{I18n.t("chats.chat.form_edit_aria")}']", visible: true
      assert_selector "a[aria-label='#{I18n.t("chats.chat.form_cancel_aria")}'][data-chats--chat-edit-target='cancelEditButton']", visible: false

      find("[data-chats--chat-edit-target='chatNameInput']").send_keys(:escape)

      assert_text original_name, wait: 5
      assert_selector "a[data-chats--chat-list-target='editChatLink']", visible: true
    end

    assert_equal original_name, Chat.find(first_chat.id).name
  end
end
