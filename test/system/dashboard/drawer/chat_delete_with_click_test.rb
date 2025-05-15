# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"


class ChatDeleteWithClickTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, :with_3_chats)
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end

  test "User deletes a chat in the drawer and sees it removed" do
    @drawer.open
    @drawer.assert_drawer_visible

    assert_selector "turbo-frame##{dom_id(@user.chats.first)}", visible: true, wait: 5
    within("turbo-frame##{dom_id(@user.chats.first)}") do
      page.accept_confirm(I18n.t("helpers.confirm")) do
        click_on I18n.t("helpers.button.delete")
      end
    end

    assert_no_selector "turbo-frame##{dom_id(@user.chats.first)}", wait: 5
  end
end
