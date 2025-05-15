# frozen_string_literal: true

require "application_system_test_case"

module Chats
  class EditTest < ApplicationSystemTestCase
    def setup
      @user = create(:user)
      @chat = create(:chat, user: @user)
    end

    test "user logs in, opens chat index, clicks edit, edits chat name, and submits via Enter key" do
      sign_in_and_visit(@user, chats_path)

      new_name = "Updated Chat Name"

      within("turbo-frame##{dom_id(@chat)}") do
        click_on I18n.t("helpers.button.rename")

        assert_selector "form[role='form'][aria-label='#{I18n.t("chats.chat.form_edit_aria")}']", visible: true
        assert_selector "input[aria-label='#{I18n.t("activerecord.models.chat.name")}'][aria-describedby='chat_name_error chat_name_hint']", visible: true

        fill_in "chat[name]", with: new_name
        find("[data-chats--chat-edit-target='chatNameInput']").send_keys(:enter)

        assert_text new_name
        assert_selector "a[data-chats--chat-list-target='editChatLink']", visible: true
        assert_selector "[data-chats--chat-list-target='editChatLink'] svg", visible: true
      end

      assert Chat.find(@chat.id).name == new_name, "Chat name should be updated in the database"
    end

    test "user logs in, opens chat index, clicks edit, enters invalid name, and sees HTML5 validation error" do
      sign_in_and_visit(@user, chats_path)

      within("turbo-frame##{dom_id(@chat)}") do
        click_on I18n.t("helpers.button.rename")

        input = find("[data-chats--chat-edit-target='chatNameInput']")
        input.set("$InvalidName")
        input.send_keys(:enter)

        assert_equal false, page.evaluate_script("arguments[0].validity.valid", input)
        # If we evaluate or execute the script, the message only contains
        # the browser's default message. The appended 'title' attribute is not included.
        # message = page.evaluate_script("arguments[0].validationMessage", input)

        # Instead of relying on the browser tooltip, assert the presence of HTML5 validation attributes
        assert_html_validation_attributes(
          input,
          pattern: Chat.strict_html_pattern,
          title: I18n.t("chats.form.name_hint")
        )
      end
    end

    test "user logs in, opens chat index, clicks edit, enters invalid name, and sees model error" do
      sign_in_and_visit(@user, chats_path)

      within("turbo-frame##{dom_id(@chat)}") do
        click_on I18n.t("helpers.button.rename")

        input = find("[data-chats--chat-edit-target='chatNameInput']")
        input.set("$InvalidName")

        # Simulate a user bypassing HTML5 validation by removing pattern and required attributes
        remove_validation_attributes(input)
        assert_selector "form[action*='#{chat_path(@chat)}']", visible: true, wait: 5
        input.send_keys(:enter)
      end

      assert_selector "input[name='chat[name]'][value='$InvalidName']"
      assert_text I18n.t("activerecord.errors.models.chat.attributes.name.invalid_characters"), wait: 5
      assert_selector "input[aria-invalid='true'][name='chat[name]']", visible: true, wait: 5
      assert_selector "div#chat_name_error[aria-live='polite']", text: I18n.t("activerecord.errors.models.chat.attributes.name.invalid_characters"), wait: 5
    end

    test "user logs in, opens chat index, clicks edit, hits escape to cancel, and sees original chat restored" do
      sign_in_and_visit(@user, chats_path)

      within("turbo-frame##{dom_id(@chat)}") do
        assert_text @chat.name
        find("a[data-chats--chat-list-target='editChatLink']").click

        assert_selector "a[aria-label='#{I18n.t("chats.chat.form_cancel_aria")}'][data-chats--chat-edit-target='cancelEditButton']", visible: false
        assert_selector "form[role='form']", visible: true

        # Wait for the form to appear
        assert_selector "form[action*='#{chat_path(@chat)}']", visible: true
        assert_selector "input[name='chat[name]']", visible: true

        # Cancel the edit by hitting escape
        find("input[name='chat[name]']").send_keys(:escape)

        # After cancel, the turbo_frame should be replaced by original chat display
        assert_text @chat.name
        assert_selector "[data-chats--chat-list-target='editChatLink']"
      end
    end

    def remove_validation_attributes(input)
      page.execute_script("arguments[0].removeAttribute('pattern')", input)
      page.execute_script("arguments[0].removeAttribute('required')", input)
    end

    def assert_html_validation_attributes(input, pattern:, required: true, title: nil)
      assert_equal pattern, input[:pattern]
      assert_equal "true", input[:required] if required
      assert_equal title, input[:title] if title
    end
  end
end
