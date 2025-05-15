# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"

class ChatEditWithEnterTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, :with_3_chats)
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end

  test "User edits a chat in the drawer and sees it updated with enter key" do
    @drawer.open
    @drawer.assert_drawer_visible

    new_name = "Updated Chat Name"
    assert_selector "turbo-frame##{dom_id(@user.chats.first)}", visible: true, wait: 5

    within("turbo-frame##{dom_id(@user.chats.first)}") do
      click_on I18n.t("helpers.button.rename")

      assert_selector "form[role='form'][aria-label='#{I18n.t("chats.chat.form_edit_aria")}']", visible: true
      assert_selector "a[aria-label='#{I18n.t("chats.chat.form_cancel_aria")}'][data-chats--chat-edit-target='cancelEditButton']", visible: false
      assert_selector "input[aria-label='#{I18n.t("activerecord.models.chat.name")}'][aria-describedby='chat_name_error chat_name_hint']", visible: true

      fill_in "chat[name]", with: new_name
      find("[data-chats--chat-edit-target='chatNameInput']").send_keys(:enter)

      assert_text new_name
      assert_selector "a[data-chats--chat-list-target='editChatLink']", visible: true
    end
  end
end
