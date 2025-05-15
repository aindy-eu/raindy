# frozen_string_literal: true

require "capybara/dsl"
require "minitest/assertions"

# test_helpers/system/dropdown_helper.rb
module TestHelpers
  module System
    class DropdownHelper
      include Capybara::DSL
      include Minitest::Assertions

      attr_accessor :assertions

      def initialize(button_id)
        @button_id = button_id
        @button = find("button##{@button_id}")
        self.assertions = 0
      end

      # Opens the dropdown by clicking the button
      def open
        @button.click
      end

      # Closes the dropdown by clicking the button again
      def close
        @button.click
      end

      # Closes the dropdown by clicking outside of it
      def close_by_clicking_outside
        find("body").click
      end

      # Checks if the dropdown is visible
      def dropdown_visible?
        has_selector?("ul[aria-labelledby='#{@button_id}']:not(.hidden)", visible: true)
        assert_equal "true", @button[:'aria-expanded']
      end

      # Checks if the dropdown is hidden
      def dropdown_hidden?
        has_selector?("ul[aria-labelledby='#{@button_id}'].hidden", visible: false)
        assert_equal "false", @button[:'aria-expanded']
      end

      def navigate_and_assert_focus(key, element_type, expected_text)
        # Press the key to move focus
        page.driver.browser.action.send_keys(key).perform
        # sleep 0.3

        # Capture the currently focused element
        focused_tag = evaluate_script("document.activeElement.tagName.toLowerCase()")
        focused_text = evaluate_script("document.activeElement.textContent.trim()")
        focused_role = evaluate_script("document.activeElement.getAttribute('role')")
        focused_target = evaluate_script("document.activeElement.getAttribute('data-components--dropdown-target')")

        # Debugging output
        # puts "Key Pressed: #{key}"
        # puts "element_type: #{element_type}"
        # puts "Focused Element: <#{focused_tag}> '#{focused_text}'"
        # puts "Role: #{focused_role}, Target: #{focused_target}"

        # Assertions
        assert_equal element_type, focused_tag, "Expected focus on a <#{element_type}> but got <#{focused_tag}>"
        assert_equal expected_text, focused_text, "Expected focus on element with text '#{expected_text}' but got '#{focused_text}'"
        assert_equal "menuitem", focused_role, "Focused element should have role='menuitem'"
        assert_equal "menuItem", focused_target, "Focused element should have data-components--dropdown-target='menuItem'"
      end
    end
  end
end
