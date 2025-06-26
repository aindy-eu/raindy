# frozen_string_literal: true

require "mobile_system_test_case"

# test/system/auth/sign_in_sign_out_mobile_test.rb
module Auth
  class SignInSignOutMobileTest < MobileSystemTestCase
    # This tests are for a visual approach of testing
    # We use a simple slow down to follow the user flow
    # Currently the tests are the same as in sign_in_sign_out_test.rb
    #
    # But with the keyboard test I figured 1 send_keys(:tab) wasn't enough
    # It was a false assumption. The first tab 'junped' to the forgot password link
    # This is exactly what are tests for - right ;)

    setup do
      @user = create(:user)
      # Remove or comment out the skip to test this mobile test
      # with a none headless browser and slow down to see what is happening.
      # Then use rails test test/system/auth/sign_in_sign_out_mobile_test.rb
      # To only test this file
      skip "Skipping all mobile sign-in tests for educational purposes"
    end

    # Debug helper method instead of our test_helpers/system/authentication_helper
    def debug_sign_in(user)
      visit new_session_path
      fill_in "email_address", with: user.email_address
      fill_in "password", with: user.password

      # Debugging wait/sleep = 1 second
      slow_down(2)

      click_button I18n.t("authentication.button.sign_in")
    end

    test "user can log in" do
      debug_sign_in(@user)
      slow_down
      assert_text I18n.t("authentication.alerts.signed_in")
    end

    test "user can log out" do
      debug_sign_in(@user)

      # To check the drop down behavior we don't use the sign_out here
      find("button#dropdown-menu-main-button").click
      slow_down(2)
      click_button I18n.t("navigations.logged_in.main_nav.sign_out")

      slow_down
      assert_text I18n.t("authentication.alerts.signed_out")
      assert_current_path new_session_url(locale: I18n.locale)
    end

    test "user can navigate login form with keyboard" do
      visit new_session_path

      fill_in "email_address", with: @user.email_address
      find("input#email_address").send_keys(:tab)
      slow_down

      fill_in "password", with: "12#34!password!43#21"
      slow_down(2)

      find("input#password").send_keys(:enter)

      slow_down
      assert_text I18n.t("authentication.alerts.signed_in")
    end

    test "user cannot sign in with wrong email" do
      @user.email_address = "none-existing@example.com"
      debug_sign_in(@user)

      slow_down
      assert_text I18n.t("authentication.alerts.invalid_credentials")
    end

    test "user cannot sign in with wrong password" do
      @user.password = "wrongpassword"
      debug_sign_in(@user)

      slow_down
      assert_text I18n.t("authentication.alerts.invalid_credentials")
    end
  end
end
