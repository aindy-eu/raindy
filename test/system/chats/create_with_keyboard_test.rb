# frozen_string_literal: true

require "application_system_test_case"

class ChatsCreateWithKeyboardTest < ApplicationSystemTestCase
  include KeyboardNavigationHelper

  setup do
    @user = create(:user)
  end

  test "user creates a chat using keyboard" do
    sign_in_and_visit(@user, chats_path)

    # Tab to navigate to the input field
    focus_element_with_tab("input#chat_chats-new-chat-name")
    assert has_selector?("input#chat_chats-new-chat-name:focus"), "Input field should be focused"

    chat_name = "My System Chat"
    fill_in "chat_chats-new-chat-name", with: chat_name

    # Tab to navigate to the create button
    focus_element_with_tab("button[aria-label='#{I18n.t("helpers.submit.create", model: Chat.model_name.human)}']")
    find("button[aria-label='#{I18n.t("helpers.submit.create", model: Chat.model_name.human)}']").send_keys(:enter)

    # Minimal verification to confirm the action worked
    within "div#chats" do
      chat_elements = all("turbo-frame")
      assert_includes chat_elements.first.text, chat_name
    end
  end
end
