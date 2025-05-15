# frozen_string_literal: true

require "application_system_test_case"

module Chats
  class DestroyWithKeyboardTest < ApplicationSystemTestCase
    include KeyboardNavigationHelper

    setup do
      @user = create(:user)
      @chat = create(:chat, user: @user)
    end

    test "user deletes a chat using the keyboard" do
      sign_in_and_visit(@user, chats_path)

      focus_element_with_tab("[data-chats--chat-list-target='deleteChat']")
      accept_confirm do
        find("[data-chats--chat-list-target='deleteChat']").send_keys(:enter)
      end

      assert_no_selector "turbo-frame##{dom_id(@chat)}", wait: 5
      assert_not Chat.exists?(@chat.id), "Chat should be deleted from the database"
    end
  end
end
