# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Add test_helpers to the load path
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].sort.each { |file| require file }


module ActiveSupport
  class TestCase
    include TestHelpers::AuthenticationHelper
    include TestHelpers::Chats::ChatHelper

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Include FactoryBot methods
    include FactoryBot::Syntax::Methods

    # Helper method (just for better readability ;) to slow down system tests if they are not 'headless'
    def slow_down(duration = 1)
      sleep duration
    end
  end
end
