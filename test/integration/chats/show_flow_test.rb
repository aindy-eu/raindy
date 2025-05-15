# frozen_string_literal: true

require "test_helper"

module Chats
  class ShowFlowTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user)
      @chat = create(:chat, user: @user)
      login_as(@user)
    end

    test "user views a chat successfully" do
      get chat_url(@chat)
      assert_response :success
      assert_match @chat.name, response.body
    end
  end
end
