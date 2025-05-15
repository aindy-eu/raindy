# frozen_string_literal: true

require "test_helper"

class ChatsControllerEditTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @chat = create(:chat, user: @user)
    login_as(@user)
  end

  test "returns edit page via HTML" do
    get edit_chat_url(@chat)
    assert_response :success
  end

  test "renders localized edit page via HTML" do
    get edit_chat_url(@chat, locale: :de)

    assert_response :success
    assert_match I18n.t("helpers.navigation.edit", locale: :de, model: Chat.model_name.human), response.body
  end

  test "redirects to chat index if editing a chat owned by another user" do
    other_user = create(:user)
    other_chat = create(:chat, user: other_user)

    login_as(@user)
    get edit_chat_url(other_chat)

    assert_redirected_to chats_url(locale: I18n.locale)
    assert_equal I18n.t("authorization.denied"), flash[:alert]
  end

  test "renders edit form inside Turbo Frame" do
    get edit_chat_url(@chat)

    assert_response :success
    assert_select "turbo-frame##{dom_id(@chat)}" do
      assert_select "form[action*='#{chat_path(@chat)}']"
      assert_select "input[name='chat[name]'][value='#{@chat.name}']"
    end
  end
end
