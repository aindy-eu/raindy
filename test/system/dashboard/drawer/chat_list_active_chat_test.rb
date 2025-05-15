# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"


class ChatListActiveChatTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, :with_3_chats)
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end

  test "User opens the drawer and sees the active chat highlighted" do
    sign_in(@user)
    assert_text I18n.t("authentication.alerts.signed_in")

    # Set the URL to the second chat to make it active
    active_chat = @user.chats.second
    visit chat_path(active_chat)
    assert_equal "/chats/#{active_chat.to_param}", page.current_path, "URL should be set to the active chat"

    @drawer.open
    @drawer.assert_drawer_visible

    assert_selector "turbo-frame##{dom_id(active_chat)}", visible: true, wait: 5

    # Verify chats are correctly (not) highlighted
    within("turbo-frame#chats_index") do
      active_chat_id = dom_id(active_chat)
      assert_selector "turbo-frame##{active_chat_id}.active-chat", wait: 5
      # Verify the active chat is highlighted
      within("turbo-frame##{active_chat_id}") do
        assert_selector "a[data-chats--chat-list-target='linkToChat'][aria-current='page']", visible: true
        assert_text active_chat.name
      end
      # Verify other chats are not highlighted
      @user.chats.where.not(id: active_chat.id).each do |chat|
        chat_id = dom_id(chat)
        assert_no_selector "turbo-frame##{chat_id}.active-chat", wait: 5
      end
    end
  end
end
