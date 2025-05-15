# frozen_string_literal: true

require "test_helper"

class ChatsControllerShowTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @chat = create(:chat, user: @user)
    login_as(@user)
  end

  test "shows chat details page with chat name and placeholder" do
    get chat_url(@chat)
    assert_response :success

    assert_match @chat.name, response.body
    assert_select "h1", text: /#{Regexp.escape(@chat.name)}/
    assert_select "div.container"
    assert_select "svg" # Copy button present
  end

  test "redirects when accessing a chat owned by another user" do
    other_user = create(:user)
    other_chat = create(:chat, user: other_user)

    login_as(@user)
    get chat_url(other_chat)

    assert_redirected_to chats_url(locale: I18n.locale)
    assert_equal I18n.t("authorization.denied"), flash[:alert]
  end
end
