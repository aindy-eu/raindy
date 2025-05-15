# frozen_string_literal: true

require "test_helper"

class ChatsControllerIndexTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    login_as(@user)
  end

  test "renders chat index page with turbo frames" do
    get chats_url
    assert_response :success
    assert_select "turbo-frame#chats_index"
    assert_select "turbo-frame#chats_new"
    assert_select "#chats[role='list']"
  end

  test "renders empty state when user has no chats" do
    get chats_url
    assert_response :success
    assert_match I18n.t("chats.no_chats"), response.body
  end

  test "renders chat list when user has chats" do
    chat1 = create(:chat, name: "Chat 1", user: @user)
    chat2 = create(:chat, name: "Chat 2", user: @user)

    get chats_url
    assert_response :success
    assert_match chat1.name, response.body
    assert_match chat2.name, response.body
    assert_select "##{dom_id(chat1)}"
    assert_select "##{dom_id(chat2)}"
  end

  test "renders localized index page" do
    get chats_url(locale: :de)
    assert_response :success
    assert_match "Chats", response.body # Update if you localize the heading later
  end

  test "redirects to login if user is not authenticated" do
    logout # from authentication_helper
    get chats_url

    assert_redirected_to new_session_url(locale: I18n.locale)
    assert_equal I18n.t("authentication.alerts.not_authenticated"), flash[:alert]
  end
end
