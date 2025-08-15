# frozen_string_literal: true

require "application_system_test_case"

class AlertAutoCloseTest < ApplicationSystemTestCase
  include TestHelpers::System::AuthenticationHelper

  setup do
    @user = create(:user)
    sign_in(@user)
  end

  test "alert auto-dismisses after delay" do
    # Insert an alert into the DOM with a short delay for testing
    page.execute_script(<<~JS)
      const alert = document.createElement('div');
      alert.setAttribute('data-controller', 'components--alert');
      alert.setAttribute('data-components--alert-delay-value', '1000');
      alert.textContent = 'This is a test alert';
      alert.classList.add('alert');
      document.body.appendChild(alert);
    JS

    # First verify the alert appears
    assert_selector ".alert", text: "This is a test alert", wait: 2

    # Wait for auto-dismiss (1 second delay + buffer time)
    # Using Capybara's built-in waiting instead of sleep
    assert_no_selector ".alert", wait: 5
  end
end
