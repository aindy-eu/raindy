# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include TestHelpers::System::AuthenticationHelper

  if ENV["CAPYBARA_SERVER_PORT"]
    served_by host: "rails-app", port: ENV["CAPYBARA_SERVER_PORT"]

    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1000 ], options: {
      browser: :remote,
      url: "http://#{ENV["SELENIUM_HOST"]}:4444"
    }
  else
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1000 ]
    # driven_by :selenium, using: :chrome, screen_size: [ 1400, 1000 ]
  end
end
