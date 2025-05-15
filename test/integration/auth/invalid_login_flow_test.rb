# frozen_string_literal: true

require "test_helper"

module Auth
  class InvalidLoginFlowTest < ActionDispatch::IntegrationTest
    setup { @user = create(:user) }

    test "user cannot sign in with wrong email" do
      post session_path, params: {
        email_address: "wrong@example.com",
        password: @user.password # correct password from factory
      }
      assert_redirected_to new_session_path(locale: I18n.locale)
      follow_redirect!

      # puts response.body
      assert_select "#flash_messages span", text: I18n.t("authentication.alerts.invalid_credentials")
    end

    test "user cannot sign in with wrong password" do
      post session_path, params: {
        email_address: @user.email_address,
        password: "wrongpassword"
      }
      assert_redirected_to new_session_path(locale: I18n.locale)
      follow_redirect!

      assert_select "#flash_messages span", text: I18n.t("authentication.alerts.invalid_credentials")
    end
  end
end
