# frozen_string_literal: true

require "test_helper"

module Chats
  class AccessProtectionFlowTest < ActionDispatch::IntegrationTest
    test "guest is redirected to login page when accessing chats index" do
      get chats_url
      assert_redirected_to new_session_url(locale: I18n.locale)
      follow_redirect!
      assert_match I18n.t("authentication.alerts.not_authenticated"), response.body
    end

    test "guest is redirected to login page when accessing new chat page" do
      get new_chat_url
      assert_redirected_to new_session_url(locale: I18n.locale)
      follow_redirect!
      assert_match I18n.t("authentication.alerts.not_authenticated"), response.body
    end

    test "guest is redirected to login page when trying to post a chat" do
      post chats_url, params: { chat: { name: "Unauthorized Chat" } }
      assert_redirected_to new_session_url(locale: I18n.locale)
    end
  end
end
