# frozen_string_literal: true

module TestHelpers
  module Shared
    module FlashHelper
      def assert_flash_message(key, value)
        assert_equal value, flash[key], "Expected flash[#{key}] to be '#{value}'"
      end

      def assert_flash_structure(rendered, key:, value:, css:)
        # Parse rendered as an HTML fragment
        assert_select Nokogiri::HTML.fragment(rendered), "div.alert[role='alert']" do
          assert_select "[data-components--alert-target='message']", text: value
          assert_select "[data-controller='components--alert']"
          assert_select "[data-components--alert-target='closeButton'][data-action=?]", "click->components--alert#close"
          assert_select "[data-components--alert-target='closeButton'][aria-label=?]", "Close"
          assert_select "div[class*=?]", css
        end
      rescue Nokogiri::CSS::SyntaxError => e
        puts "Nokogiri CSS Syntax Error: #{e.message}"
        # Explicitly fail the test with a custom error message if HTML parsing fails.
        flunk "Failed to parse HTML due to CSS syntax error: #{e.message}"
      end

      def assert_turbo_flash(target)
        assert_turbo_stream action: "replace", target: target do
          assert_select "#dialog_flash_messages" if target == "dialog_flash_messages"
          assert_select "#flash_messages" if target == "flash_messages"
        end
      end
    end
  end
end
