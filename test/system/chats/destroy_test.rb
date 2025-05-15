# frozen_string_literal: true

require "application_system_test_case"

module Chats
  class DestroyTest < ApplicationSystemTestCase
    setup do
      @user = create(:user)
      # Ensure @next_chat appears first in the list (created_at DESC)
      @next_chat = create(:chat, user: @user, created_at: 1.day.from_now)
      @chat = create(:chat, user: @user, created_at: 2.days.ago)
    end

    test "user deletes a chat by clicking the delete button" do
      sign_in_and_visit(@user, chats_path)

      within("turbo-frame##{dom_id(@chat)}") do
        accept_confirm do
          click_on I18n.t("helpers.button.delete")
        end
      end

      assert_no_selector "turbo-frame##{dom_id(@chat)}", wait: 5
      assert_not Chat.exists?(@chat.id), "Chat should be deleted from the database"
    end
  end
end
