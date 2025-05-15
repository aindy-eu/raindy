# frozen_string_literal: true

require "test_helper"

class ChatsControllerUpdateTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @chat = create(:chat, user: @user)
    login_as(@user)
  end

  test "updates chat via HTML" do
    html_update_chat(@chat, name: "Updated Name")

    assert_redirected_to chat_url(@chat, locale: I18n.locale)
    assert_equal I18n.t("helpers.updated", model: Chat.model_name.human), flash[:notice]
    assert_equal "Updated Name", @chat.reload.name
  end

  test "fails to update chat via HTML with invalid attributes" do
    html_update_chat(@chat, name: "")

    assert_response :unprocessable_entity
    assert_not_equal "", @chat.reload.name
  end

  test "updates chat via Turbo Stream and replaces chat and flash messages" do
    turbo_update_chat(@chat, name: "Updated Turbo Chat")

    assert_turbo_stream action: "replace", target: dom_id(@chat)
    assert_turbo_stream action: "replace", target: "dialog_flash_messages"
    assert_equal "Updated Turbo Chat", @chat.reload.name
  end

  test "fails to update chat via Turbo Stream with invalid attributes" do
    turbo_update_chat(@chat, name: "")

    assert_turbo_stream status: :unprocessable_entity, action: "replace", target: dom_id(@chat)
    assert_not_equal "", @chat.reload.name
  end

  test "renders chat edit form with validation errors via Turbo Stream" do
    turbo_update_chat(@chat, name: "")

    assert_turbo_stream status: :unprocessable_entity, action: "replace", target: dom_id(@chat) do
      assert_select "form[data-controller='chats--chat-edit']"
      assert_select "div[role='tooltip']", text: /ausgefüllt/
    end
  end

  test "responds to turbo_stream format" do
    turbo_update_chat(@chat, name: "Updated Turbo Chat")

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "unauthenticated user cannot update chat" do
    logout
    html_update_chat(@chat, name: "Unauthorized Update")
    assert_redirected_to new_session_url(locale: I18n.locale)
    assert_equal I18n.t("authentication.alerts.not_authenticated"), flash[:alert]
    assert_not_equal "Unauthorized Update", @chat.reload.name
  end
end
