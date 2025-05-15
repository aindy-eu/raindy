# frozen_string_literal: true

require "test_helper"

module Chats
  class CreateFlowTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user)
      login_as(@user)
    end

    test "user creates a chat and sees it listed" do
      # Step 1: Post the chat creation
      html_create_chat(name: "Integration Chat")
      follow_redirect!

      # Step 2: Assert redirect worked and chat appears
      assert_response :success
      assert_match "Integration Chat", response.body
      assert_match I18n.t("helpers.created", model: Chat.model_name.human), response.body
    end

    test "user creates a chat via Turbo Stream and sees it appear in chat list" do
      turbo_create_chat(name: "Turbo Integration Chat")

      assert_turbo_stream action: "prepend", target: "chats"
      assert_turbo_stream action: "update", target: "chats_new"
      assert Chat.exists?(name: "Turbo Integration Chat")
    end

    test "chat creation fails with invalid name and form re-renders" do
      html_create_chat(name: "")

      assert_response :unprocessable_entity
      assert_select "form[action*='#{chats_path}']"

      assert_chat_name_errors
    end

    test "user fails to create chat with expired session" do
      logout
      turbo_create_chat(name: "Expired Session Chat")
      assert_redirected_to new_session_url(locale: I18n.locale)
      assert_equal I18n.t("authentication.alerts.not_authenticated"), flash[:alert]
      assert_not Chat.exists?(name: "Expired Session Chat")
    end
  end
end
