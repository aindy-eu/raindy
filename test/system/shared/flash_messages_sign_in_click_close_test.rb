# frozen_string_literal: true

require "application_system_test_case"

class FlashMessagesSignInClickCloseTest < ApplicationSystemTestCase
  include TestHelpers::Shared::FlashHelper
  include TestHelpers::System::AuthenticationHelper

  setup do
    @user = create(:user)
    sign_in(@user)
  end

  test "alert closes when clicking close button" do
    assert_text I18n.t("authentication.alerts.signed_in")

    alert_selector = "div.alert[data-controller='components--alert']"
    assert_selector alert_selector

    find("[data-components--alert-target='closeButton']").click
    assert_no_selector alert_selector, wait: 2
  end
end
