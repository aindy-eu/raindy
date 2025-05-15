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
      alert.setAttribute('data-components--alert-delay-value', '2000');
      alert.textContent = 'This is a test alert';
      alert.classList.add('alert');
      document.body.appendChild(alert);
    JS

    assert_selector ".alert", text: "This is a test alert", wait: 5

    sleep 10 # Wait a bit longer than the 1-second auto-dismiss

    assert_no_selector ".alert", wait: 5
  end
end
