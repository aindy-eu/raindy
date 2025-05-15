# frozen_string_literal: true

require "test_helper"

class FlashMessagesFlowTest < ActionDispatch::IntegrationTest
  include TestHelpers::Shared::FlashHelper

  setup do
    @user = create(:user)
    @chat = create(:chat, user: @user)
    login_as(@user)
  end

  test "user sees flash message after destroying chat via HTML" do
    delete chat_url(@chat)
    assert_redirected_to chats_url(locale: I18n.locale)
    follow_redirect!
    assert_flash_message("notice", I18n.t("helpers.deleted", model: Chat.model_name.human))
  end

  test "user sees flash message after destroying chat via Turbo Stream" do
    delete chat_url(@chat, format: :turbo_stream)
    assert_turbo_flash("dialog_flash_messages")
    assert_flash_message("success", I18n.t("helpers.deleted", model: Chat.model_name.human))
  end

  test "user sees flash message after signing in" do
    logout
    post session_path, params: { email_address: @user.email_address, password: @user.password }
    assert_redirected_to root_path(locale: I18n.locale)
    follow_redirect!
    assert_flash_message("notice", I18n.t("authentication.alerts.signed_in"))
  end
end
