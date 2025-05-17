# frozen_string_literal: true

require "test_helper"

class ChatsControllerCreateTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    login_as(@user)
  end

  test "creates chat via HTML" do
    assert_difference("Chat.count") do
      html_create_chat(name: "HTML Chat")
    end

    assert_redirected_to chats_url(locale: I18n.locale)
    assert_equal I18n.t("helpers.created", model: Chat.model_name.human), flash[:notice]
  end

  test "fails to create chat via HTML with invalid params" do
    assert_no_difference("Chat.count") do
      html_create_chat(name: "")
    end

    assert_response :unprocessable_entity
    assert_chat_name_errors
  end

  test "creates chat via Turbo Stream" do
    assert_difference("Chat.count") do
      turbo_create_chat(name: "Turbo Chat")
    end

    assert_turbo_stream action: "prepend", target: "chats"
    assert_turbo_stream action: "update", target: "chats_new"
  end

  test "fails to create chat via Turbo Stream with invalid params" do
    assert_no_difference("Chat.count") do
      turbo_create_chat(name: "")
    end

    assert_turbo_stream status: :unprocessable_entity, action: "update", target: "chats_new"
  end

  test "create replaces form with errors and preserves user input" do
    turbo_create_chat(name: "$Invalid")

    assert_turbo_stream status: :unprocessable_entity, action: "update", target: "chats_new" do
      assert_select "input[name='chat[name]'][value='$Invalid']", count: 1
      # Server-side validation is tested here; JS tooltip testing should be handled in system tests
      # assert_select "div[role='tooltip']", I18n.t("activerecord.errors.models.chat.attributes.name.invalid_characters")
    end
  end

  test "responds to turbo_stream format" do
    turbo_create_chat(name: "Turbo Chat")

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "unauthenticated user cannot create chat" do
    logout
    assert_no_difference("Chat.count") do
      html_create_chat(name: "Unauthorized Chat")
    end
    assert_redirected_to new_session_url(locale: I18n.locale)
    assert_equal I18n.t("authentication.alerts.not_authenticated"), flash[:alert]
  end
end
