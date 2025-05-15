# frozen_string_literal: true

require "test_helper"

module Chats
  class DestroyFlowTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user)
      @chat = create(:chat, user: @user)
      login_as(@user)
    end

    test "user destroys a chat successfully via HTML" do
      assert_difference("Chat.count", -1) do
        delete chat_url(@chat)
      end

      assert_redirected_to chats_url(locale: I18n.locale)
      follow_redirect!

      assert_response :success
      assert_match I18n.t("helpers.deleted", model: Chat.model_name.human), response.body
      refute Chat.exists?(@chat.id)
    end

    test "user destroys a chat successfully via Turbo Stream" do
      assert_difference("Chat.count", -1) do
        delete chat_url(@chat, format: :turbo_stream)
      end

      assert_turbo_stream action: "remove", target: dom_id(@chat)
      assert_turbo_stream action: "replace", target: "dialog_flash_messages"
      refute Chat.exists?(@chat.id)
    end

    test "user fails to destroy another user's chat" do
      other_user = create(:user)
      other_chat = create(:chat, user: other_user)

      assert_no_difference("Chat.count") do
        delete chat_url(other_chat)
      end

      assert_redirected_to chats_url(locale: I18n.locale)
      follow_redirect!

      assert_match I18n.t("authorization.denied"), response.body
    end
  end
end
