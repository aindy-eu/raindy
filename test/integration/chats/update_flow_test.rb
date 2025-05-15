# frozen_string_literal: true

require "test_helper"

module Chats
  class UpdateFlowTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user)
      @chat = create(:chat, user: @user)
      login_as(@user)
    end

    test "user updates a chat successfully via HTML" do
      html_update_chat(@chat, name: "Updated Name")
      follow_redirect!

      assert_response :success
      assert_match "Updated Name", response.body
      assert_match I18n.t("helpers.updated", model: Chat.model_name.human), response.body
    end

    test "user fails to update a chat via HTML with invalid data" do
      html_update_chat(@chat, name: "")

      assert_response :unprocessable_entity
      assert_select "form[action*='#{chat_path(@chat)}']"
      assert_chat_name_errors
    end

    test "user updates chat via Turbo Stream and sees updated chat in list" do
      turbo_update_chat(@chat, name: "Updated Turbo Chat")

      assert_turbo_stream action: "replace", target: dom_id(@chat)
      assert_turbo_stream action: "replace", target: "dialog_flash_messages"
      assert Chat.exists?(name: "Updated Turbo Chat")
    end

    test "user fails to update chat via Turbo Stream and sees form errors" do
      turbo_update_chat(@chat, name: "")

      assert_response :unprocessable_entity
      assert_turbo_stream status: :unprocessable_entity, action: "replace", target: dom_id(@chat) do
        assert_select "form[action*='#{chat_path(@chat)}']"
        assert_chat_name_errors
      end
    end
  end
end
