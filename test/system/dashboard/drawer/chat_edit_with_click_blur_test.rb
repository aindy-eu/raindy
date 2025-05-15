# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"


class ChatEditWithClickBlurTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, :with_3_chats)
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end

  test "User edits a chat in the drawer and sees it updated by clicking outside (blur)" do
    @drawer.open
    @drawer.assert_drawer_visible

    new_name = "Updated Chat Name (again, again)"
    assert_selector "turbo-frame##{dom_id(@user.chats.first)}", visible: true, wait: 5

    within("turbo-frame##{dom_id(@user.chats.first)}") do
      click_on I18n.t("helpers.button.rename")
      fill_in "chat[name]", with: new_name
    end

    find("div#chats").click

    within("turbo-frame##{dom_id(@user.chats.first)}") do
      assert_text new_name
      assert_selector "a[data-chats--chat-list-target='editChatLink']", visible: true
    end
  end
end
