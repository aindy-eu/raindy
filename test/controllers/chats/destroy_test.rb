# frozen_string_literal: true

require "test_helper"

class ChatsControllerDestroyTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @chat = create(:chat, user: @user)
    login_as(@user)
  end

  test "destroys chat via HTML and redirects with flash" do
    assert_difference("Chat.count", -1) do
      delete chat_url(@chat)
    end

    assert_redirected_to chats_url(locale: I18n.locale)
    assert_equal I18n.t("helpers.deleted", model: Chat.model_name.human), flash[:notice]
  end

  test "destroys chat via Turbo Stream, removes chat from list and shows flash" do
    assert_difference("Chat.count", -1) do
      delete chat_url(@chat, format: :turbo_stream)
    end

    assert_turbo_stream action: "remove", target: dom_id(@chat)
    assert_turbo_stream action: "replace", target: "dialog_flash_messages"
  end

  test "responds to turbo_stream format" do
    delete chat_url(@chat, format: :turbo_stream)

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "unauthenticated user cannot destroy chat" do
    logout
    assert_no_difference("Chat.count") do
      delete chat_url(@chat)
    end
    assert_redirected_to new_session_url(locale: I18n.locale)
    assert_equal I18n.t("authentication.alerts.not_authenticated"), flash[:alert]
  end
end
