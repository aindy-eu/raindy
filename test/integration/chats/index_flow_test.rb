# frozen_string_literal: true

require "test_helper"

module Chats
  class IndexFlowTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user, :with_3_chats)
      login_as(@user)
    end

    test "user sees chat list after login" do
      get chats_url

      assert_response :success
      assert_select "turbo-frame#chats_index"
      # puts response.body
      # Check that 3 chats are actually rendered
      @user.chats.each do |chat|
        assert_select "a[href='#{chat_path(chat, locale: I18n.locale)}']", text: chat.name
      end
    end
  end
end
