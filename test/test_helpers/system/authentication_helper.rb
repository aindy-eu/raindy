# frozen_string_literal: true

module TestHelpers
  module System
    module AuthenticationHelper
      def sign_in(user)
        visit new_session_url
        fill_in "email_address", with: user.email_address
        fill_in "password", with: user.password
        click_button I18n.t("authentication.button.sign_in")
      end

      def sign_in_and_visit(user, path)
        # Note: Signing in inside `setup` caused timing issues with Turbo transitions.
        # By signing in AND asserting the flash, we ensure the UI is fully ready before continuing.
        sign_in(user)
        assert_text I18n.t("authentication.alerts.signed_in")
        visit path
      end

      def sign_out
        find("button#dropdown-menu-main-button").click
        click_button I18n.t("navigations.logged_in.main_nav.sign_out")
      end
    end
  end
end
