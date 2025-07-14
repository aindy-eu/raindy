# frozen_string_literal: true

require "capybara/dsl"
require "minitest/assertions"

module TestHelpers
  module System
    class DrawerHelper
      include Capybara::DSL
      include Minitest::Assertions

      attr_accessor :assertions

      def initialize
        self.assertions = 0
        # Cache the drawer button and drawer element
        @drawer_button = find("button[data-components--drawer-target='drawerButton']")
        # The dialog may not be visible at first, so we find it with visible: false
        @drawer = find("dialog[data-components--drawer-target='dialog']", visible: false)
      end

      def dialog_element
        @drawer
      end

      # Opens the drawer by clicking the drawer button.
      def open
        @drawer_button.click
      end

      # Closes the drawer by clicking the close button within the drawer.
      def assert_and_close_by_button
        close_btn = find("button[data-action='components--drawer#close']")
        assert_equal I18n.t("navigations.logged_in.chats_nav.close"), close_btn[:'aria-label']
        close_btn.click
        # Small sleep to ensure animations complete in CI environment
        sleep 0.1
      end

      # Closes the drawer by clicking outside (the backdrop).
      def close_by_backdrop
        find("body").click
        # Small sleep to ensure animations complete in CI environment
        sleep 0.1
      end

      # Closes the drawer by sending the Escape key.
      def close_by_escape
        @drawer.send_keys(:escape)
        # Small sleep to ensure animations complete in CI environment
        sleep 0.1
      end

      # Returns true if the drawer is visible (i.e. aria-hidden="false" and shown)
      def visible?
        has_selector?("dialog[data-components--drawer-target='dialog'][aria-hidden='false']", visible: true)
      end

      # Returns true if the drawer is hidden (i.e. aria-hidden="true")
      def hidden?
        has_selector?("dialog[data-components--drawer-target='dialog'][aria-hidden='true']", visible: false)
      end

      # Convenience assertions.
      def assert_drawer_visible
        assert_equal true, visible?, "Expected drawer to be visible"
      end

      def assert_drawer_hidden
        assert_equal true, hidden?, "Expected drawer to be hidden"
      end
    end
  end
end
