# frozen_string_literal: true

require "test_helper"

class ChatsControllerDrawerListItemTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @chat = create(:chat, user: @user)
    login_as(@user)
  end

  test "returns drawer_list_item view via HTML" do
    get drawer_list_item_chat_url(@chat)
    assert_response :success
  end

  test "renders drawer_list_item view via Turbo Frame" do
    # Simulate a Turbo Frame request (pattern from turbo-rails test suite):
    # https://github.com/hotwired/turbo-rails/blob/main/test/frames/frame_request_controller_test.rb
    get drawer_list_item_chat_path(@chat, locale: :de), headers: { "Turbo-Frame" => dom_id(@chat) }

    assert_response :success
    assert_match @chat.name, response.body
    assert_select "turbo-frame##{dom_id(@chat)}"
  end
end
