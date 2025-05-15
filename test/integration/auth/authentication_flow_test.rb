# frozen_string_literal: true

require "test_helper"

module Auth
  class AuthenticationFlowTest < ActionDispatch::IntegrationTest
    setup { @user = create(:user) }

    test "user signs in successfully and sees dashboard buttons for drawer and dropdown" do
      post session_url, params: {
        email_address: @user.email_address,
        password: "12#34!password!43#21" # hardcoded in factory
      }
      assert_redirected_to root_path(locale: I18n.locale)
      follow_redirect!
      assert_response :success
      assert_match I18n.t("authentication.alerts.signed_in"), response.body
      assert_select "button[data-components--drawer-target='drawerButton']"
      assert_select "button[data-components--dropdown-target='menuButton']"
    end

    test "user signs out and is redirected to login" do
      post session_url, params: {
        email_address: @user.email_address,
        password: "12#34!password!43#21"
      }
      follow_redirect!

      logout # from authentication_helper
      follow_redirect!

      # We assert we're on the login page:
      assert_select "form[action*='#{session_path}']"
      assert_match I18n.t("authentication.alerts.signed_out"), response.body
    end
  end
end
