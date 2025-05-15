# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"

class FlashMessagesDrawerClickCloseTest < ApplicationSystemTestCase
  include TestHelpers::System::AuthenticationHelper

  setup do
    @user = create(:user, :with_3_chats)
    @chat = @user.chats.first
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end

  test "user sees flash message after updating chat in drawer and closes it with close button" do
    @drawer.open
    @drawer.assert_drawer_visible

    new_name = "Updated Chat Name"
    assert_selector "turbo-frame##{dom_id(@user.chats.first)}", visible: true, wait: 5

    within("turbo-frame##{dom_id(@user.chats.first)}") do
      click_on I18n.t("helpers.button.rename")

      fill_in "chat[name]", with: new_name
      find("[data-chats--chat-edit-target='chatNameInput']").send_keys(:enter)

      assert_text new_name
      assert_selector "a[data-chats--chat-list-target='editChatLink']", visible: true
    end

    flash_selector = "#dialog_flash_messages .alert"
    assert_selector flash_selector, wait: 5
    find("#{flash_selector} button[aria-label='Close']").click
    assert_no_selector flash_selector, wait: 5
  end
end
