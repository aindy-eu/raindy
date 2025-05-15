# frozen_string_literal: true

require "application_system_test_case"

module Chats
  class EditWithKeyboardTest < ApplicationSystemTestCase
    include KeyboardNavigationHelper

    setup do
      @user = create(:user)
      @chat = create(:chat, user: @user)
    end

    test "user starts editing a chat using keyboard" do
      sign_in_and_visit(@user, chats_path)

      # Navigate to the Rename link and start editing
      focus_element_with_tab("a[data-chats--chat-list-target='editChatLink']")
      find("a[data-chats--chat-list-target='editChatLink']").send_keys(:enter)

      within("turbo-frame##{dom_id(@chat)}") do
        assert_selector "form[action*='#{chat_path(@chat)}']", visible: true
        assert_selector "input[name='chat[name]'][value='#{@chat.name}']", visible: true
      end
    end

    test "user edits chat name and submits with Enter key" do
      sign_in_and_visit(@user, chats_path)

      focus_element_with_tab("a[data-chats--chat-list-target='editChatLink']")
      find("a[data-chats--chat-list-target='editChatLink']").send_keys(:enter)

      new_name = "Updated Chat Enter"
      within("turbo-frame##{dom_id(@chat)}") do
        fill_in "chat[name]", with: new_name
        find("[data-chats--chat-edit-target='chatNameInput']").send_keys(:enter)

        assert_text new_name
        assert_selector "a[data-chats--chat-list-target='editChatLink']", visible: true
      end

      assert Chat.find(@chat.id).name == new_name, "Chat name should be updated in the database"
    end

    test "user edits chat name and submits on blur" do
      sign_in_and_visit(@user, chats_path)

      focus_element_with_tab("a[data-chats--chat-list-target='editChatLink']")
      find("a[data-chats--chat-list-target='editChatLink']").send_keys(:enter)

      new_name = "Updated Chat Blur"
      within("turbo-frame##{dom_id(@chat)}") do
        fill_in "chat[name]", with: new_name
        # Simulate blur by tabbing away
        find("[data-chats--chat-edit-target='chatNameInput']").send_keys(:tab)

        assert_text new_name, wait: 5
        assert_selector "a[data-chats--chat-list-target='editChatLink']", visible: true
      end

      assert Chat.find(@chat.id).name == new_name, "Chat name should be updated in the database"
    end

    test "user edits chat name and submits with Tab key" do
      sign_in_and_visit(@user, chats_path)

      focus_element_with_tab("a[data-chats--chat-list-target='editChatLink']")
      find("a[data-chats--chat-list-target='editChatLink']").send_keys(:enter)

      new_name = "Updated Chat Tab"
      within("turbo-frame##{dom_id(@chat)}") do
        fill_in "chat[name]", with: new_name
        find("[data-chats--chat-edit-target='chatNameInput']").send_keys(:tab)

        assert_text new_name, wait: 5
        assert_selector "a[data-chats--chat-list-target='editChatLink']", visible: true
      end

      assert Chat.find(@chat.id).name == new_name, "Chat name should be updated in the database"
    end

    test "user edits chat name and submits with Shift+Tab key" do
      sign_in_and_visit(@user, chats_path)

      focus_element_with_tab("a[data-chats--chat-list-target='editChatLink']")
      find("a[data-chats--chat-list-target='editChatLink']").send_keys(:enter)

      new_name = "Updated Chat Shift Tab"
      within("turbo-frame##{dom_id(@chat)}") do
        fill_in "chat[name]", with: new_name
        find("[data-chats--chat-edit-target='chatNameInput']").send_keys([ :shift, :tab ])

        assert_text new_name, wait: 5
        assert_selector "a[data-chats--chat-list-target='editChatLink']", visible: true
      end

      assert Chat.find(@chat.id).name == new_name, "Chat name should be updated in the database"
    end

    test "user starts editing and cancels with Escape key" do
      sign_in_and_visit(@user, chats_path)

      focus_element_with_tab("a[data-chats--chat-list-target='editChatLink']")
      find("a[data-chats--chat-list-target='editChatLink']").send_keys(:enter)

      within("turbo-frame##{dom_id(@chat)}") do
        assert_selector "form[action*='#{chat_path(@chat)}']", visible: true, wait: 5
        fill_in "chat[name]", with: "Unsaved Name"
        find("[data-chats--chat-edit-target='chatNameInput']").send_keys(:escape)

        assert_text @chat.name
        assert_selector "a[data-chats--chat-list-target='editChatLink']", visible: true
      end

      assert Chat.find(@chat.id).name == @chat.name, "Chat name should not be updated in the database"
    end
  end
end
