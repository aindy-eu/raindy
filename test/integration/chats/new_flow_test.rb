# frozen_string_literal: true

require "test_helper"

module Chats
  class NewFlowTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user)
      login_as(@user)
    end

    test "user opens new chat form via HTML" do
      get new_chat_url(locale: I18n.locale)
      assert_response :success

      assert_select "form#chats_new_form_new[action*='#{chats_path(locale: I18n.locale)}']"
      assert_select "input[name='chat[name]']"
      assert_select "button[type='submit']"
    end

    test "user opens new chat form inside turbo frame" do
      get new_chat_url(locale: I18n.locale), headers: { "Turbo-Frame" => "chats_new" }
      assert_response :success

      assert_select "turbo-frame#chats_new" do
        assert_select "form[action*='#{chats_path(locale: I18n.locale)}']"
      end
    end

    test "user sees localized title on new chat page" do
      get new_chat_url(locale: :de)
      assert_response :success

      assert_match I18n.t("helpers.navigation.new", locale: :de, model: Chat.model_name.human), response.body
    end

    test "guest is redirected to login when trying to access new chat form" do
      logout
      get new_chat_url(locale: I18n.locale)

      assert_redirected_to new_session_url(locale: I18n.locale)
      follow_redirect!
      assert_match I18n.t("authentication.alerts.not_authenticated"), response.body
    end
  end
end
