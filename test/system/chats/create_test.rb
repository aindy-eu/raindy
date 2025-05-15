# frozen_string_literal: true

require "application_system_test_case"

class ChatsCreateTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
  end

  test "user creates a new chat" do
    sign_in_and_visit(@user, chats_path)

    chat_name = "My System Chat"

    # We use always 'turbo-frame' identifier
    within "turbo-frame#chats_new" do
      fill_in "chat_chats-new-chat-name", with: chat_name
      # This button contains an icon, so we use the aria-label
      find("button[aria-label='#{I18n.t("helpers.submit.create", model: Chat.model_name.human)}']").click
    end

    # Verify Turbo Stream prepended the chat to the chats list
    # puts page.html
    within "div#chats" do
      chat_elements = all("turbo-frame")
      assert_includes chat_elements.first.text, chat_name
    end

    input_field = find("input#chat_chats-new-chat-name", visible: true)
    assert_equal "", input_field.value, "Input should be empty"
    # Verify the no chats hint is not present
    assert_no_selector "turbo-frame#chats_index p#no_chats_hint"
    assert Chat.exists?(name: chat_name), "Chat should be created in the database"
  end

  # We have model and integration tests for validation
  # to test html validation hints is kind of tricky
  # so we don't test them here
end
