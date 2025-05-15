# frozen_string_literal: true

require "application_system_test_case"

# test/system/auth/sign_in_sign_out_test.rb
module Auth
  class SignInSignOutTest < ApplicationSystemTestCase
    setup do
      @user = create(:user)
    end

    test "user can log in" do
      sign_in(@user)
      assert_text I18n.t("authentication.alerts.signed_in")
    end

    test "user can log out" do
      sign_in(@user)
      sign_out
      assert_text I18n.t("authentication.alerts.signed_out")
      assert_current_path new_session_url(locale: I18n.locale)
    end

    test "user can navigate login form with keyboard" do
      visit new_session_url

      # Email has auto focus
      fill_in "email_address", with: @user.email_address

      # Tab will bring you to the password input
      find("input#email_address").send_keys(:tab)

      fill_in "password", with: @user.password

      # Submit the form
      find("input#password").send_keys(:enter)
      assert_text I18n.t("authentication.alerts.signed_in")
    end

    test "user cannot sign in with wrong email" do
      @user.email_address = "none-existing@example.com"
      sign_in(@user)
      assert_text I18n.t("authentication.alerts.invalid_credentials")
    end

    test "user cannot sign in with wrong password" do
      @user.password = "wrongpassword"
      sign_in(@user)
      assert_text I18n.t("authentication.alerts.invalid_credentials")
    end
  end
end
