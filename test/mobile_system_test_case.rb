# frozen_string_literal: true

require "test_helper"

# test/mobile_system_test_case.rb
class MobileSystemTestCase < ActionDispatch::SystemTestCase
  Capybara.default_max_wait_time = 2

  # iPhone 15 Pro has a 6.1-inch screen with a screen size (resolution):
  # 1179px × 2556px , 393px × 852px viewport 1, and a CSS Pixel Ratio of 3
  driven_by :selenium, using: :chrome, screen_size: [ 393, 852 ]

  include TestHelpers::System::AuthenticationHelper
end
