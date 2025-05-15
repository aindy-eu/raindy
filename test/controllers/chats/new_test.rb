# frozen_string_literal: true

require "test_helper"

class ChatsControllerNewTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    login_as(@user)
  end

  test "renders new chat form via HTML" do
    get new_chat_url
    assert_response :success

    assert_select "form#chats_new_form_new[action*='#{chats_path}']" do
      assert_select "input[name='chat[name]']"
      assert_select "label[for='chat_chats-new-chat-name']"
      assert_select "button[type='submit']"
    end
  end

  test "renders new chat form inside turbo frame" do
    get new_chat_url, headers: { "Turbo-Frame" => "chats_new" }
    assert_response :success

    assert_select "turbo-frame#chats_new" do
      assert_select "form[action*='#{chats_path}']"
    end
  end

  test "renders localized new chat page" do
    get new_chat_url(locale: :de)
    assert_response :success

    assert_match I18n.t("helpers.navigation.new", model: Chat.model_name.human), response.body
  end

  test "redirects to login if user is not authenticated" do
    logout # from authentication_helper
    get new_chat_url

    assert_redirected_to new_session_url(locale: I18n.locale)
    assert_equal I18n.t("authentication.alerts.not_authenticated"), flash[:alert]
  end

  test "sets proper cache headers" do
    get new_chat_url
    assert_equal "max-age=0, private, must-revalidate", response.headers["Cache-Control"]
  end
end
