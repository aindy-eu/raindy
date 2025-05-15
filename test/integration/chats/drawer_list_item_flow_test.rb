# frozen_string_literal: true

require "test_helper"

module Chats
  class DrawerListItemFlowTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user)
      @chat = create(:chat, user: @user)
      login_as(@user)
    end

    test "user loads chat drawer list item via Turbo Frame" do
      get drawer_list_item_chat_url(@chat, locale: I18n.locale), headers: { "Turbo-Frame" => dom_id(@chat) }

      assert_response :success
      assert_select "turbo-frame##{dom_id(@chat)}" do
        assert_select "a[href*='#{chat_path(@chat, locale: I18n.locale)}']", text: @chat.name
      end
    end
  end
end
