# frozen_string_literal: true

require "test_helper"

module Chats
  class EditFlowTest < ActionDispatch::IntegrationTest
    setup do
      @user = create(:user)
      @chat = create(:chat, user: @user)
      login_as(@user)
    end

    test "user opens chat edit form successfully via HTML with embedded turbo frame" do
      get edit_chat_url(@chat)

      assert_response :success

      # The edit view embeds the form inside a Turbo Frame.
      # This is crucial because Hotwire/Turbo expects a frame to target and replace on navigation.
      assert_select "turbo-frame##{dom_id(@chat)}" do
        assert_select "form[action*='#{chat_path(@chat)}']"
        assert_select "input[name='chat[name]'][value='#{@chat.name}']"
      end
    end

    test "user cannot edit another user's chat" do
      other_user = create(:user)
      other_chat = create(:chat, user: other_user)

      get edit_chat_url(other_chat)

      assert_redirected_to chats_url(locale: I18n.locale)
      follow_redirect!

      assert_match I18n.t("authorization.denied"), response.body
    end
  end
end
