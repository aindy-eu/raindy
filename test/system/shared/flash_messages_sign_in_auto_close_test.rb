# frozen_string_literal: true

require "application_system_test_case"

class FlashMessagesSignInTest < ApplicationSystemTestCase
  include TestHelpers::Shared::FlashHelper
  include TestHelpers::System::AuthenticationHelper

  setup do
    @user = create(:user)
    sign_in(@user)
  end

  test "alert auto-dismisses after delay" do
    assert_text I18n.t("authentication.alerts.signed_in")

    alert_selector = "div.alert[data-controller='components--alert']"
    assert_selector alert_selector
    assert_no_selector alert_selector, wait: Constants::ALERT_TEST_DELAY / 1000.0 + 1
  end
end
