# frozen_string_literal: true

require "application_system_test_case"

module Stimulus
  module Components
    module Dropdown
      class MainNavigationDropdownTest < ApplicationSystemTestCase
        include KeyboardNavigationHelper

        setup do
          @user = create(:user)
          sign_in(@user)
          @dropdown = TestHelpers::System::DropdownHelper.new("dropdown-menu-main-button")
        end

        test "main navigation dropdown opens when clicked" do
          assert @dropdown.dropdown_hidden?, "Dropdown should be hidden initially"

          # Open the main navigation menu / dropdown
          @dropdown.open
          assert @dropdown.dropdown_visible?, "Dropdown should be visible after opening"

          # Close the main navigation menu / dropdown
          @dropdown.close
          assert @dropdown.dropdown_hidden?, "Dropdown should be hidden after closing"

          # Verify focus returns to the dropdown button.
          assert_selector("button#dropdown-menu-main-button:focus")
        end

        # Test: Main navigation dropdown closes when clicking outside
        test "main navigation dropdown closes when clicking outside" do
          @dropdown.open
          assert @dropdown.dropdown_visible?, "Dropdown should be visible after opening"

          # Click on the 'body'
          @dropdown.close_by_clicking_outside
          assert @dropdown.dropdown_hidden?, "Dropdown should be hidden after clicking outside"

          # Verify focus returns to the dropdown button.
          assert_selector("button#dropdown-menu-main-button:focus")
        end

        test "main navigation dropdown is keyboard accessible" do
          # Tab to navigate to the menu button
          focus_element_with_tab("button#dropdown-menu-main-button")

          assert has_selector?("button#dropdown-menu-main-button:focus"), "Menu button should be focused"

          # Open dropdown with Enter key
          #
          # Important - send_keys (:up, :down, :left, :right)
          # doesn't work with find("body") ...
          # In the DropdownHelper we use instead the
          # page.driver.browser.action to test the keys correctly
          find("button#dropdown-menu-main-button").send_keys(:enter)
          assert @dropdown.dropdown_visible?, "Dropdown should open when pressing Enter"

          # The first element (sign out button) should be focused
          assert has_selector?("[role='menuitem']:focus"), "First menu item should be focused"
          assert has_selector?("[data-components--dropdown-target='menuItem']:focus"), "First menu item should be focused"
          assert_selector("button", text: I18n.t("navigations.logged_in.main_nav.sign_out"), focused: true)

          # Navigate down through menu items
          @dropdown.navigate_and_assert_focus(:down, "a", I18n.t("navigations.logged_in.main_nav.chats"))
          @dropdown.navigate_and_assert_focus(:down, "a", I18n.t("navigations.logged_in.main_nav.home"))
          @dropdown.navigate_and_assert_focus(:down, "button", I18n.t("navigations.logged_in.main_nav.reload"))

          # Navigate up
          @dropdown.navigate_and_assert_focus(:left, "a", I18n.t("navigations.logged_in.main_nav.home"))
          # Navigate left - which is 'up'
          @dropdown.navigate_and_assert_focus(:up, "a", I18n.t("navigations.logged_in.main_nav.chats"))
          # Navigate right - which is 'down'
          @dropdown.navigate_and_assert_focus(:right, "a", I18n.t("navigations.logged_in.main_nav.home"))

          # Close dropdown with Escape key
          page.driver.browser.action.send_keys(:escape).perform
          assert @dropdown.dropdown_hidden?, "Dropdown should be hidden when pressing Escape"

          # Verify focus returns to the dropdown button.
          assert_selector("button#dropdown-menu-main-button:focus")
        end

        test "main navigation dropdown is not accessible to unauthenticated users" do
          sign_out
          assert has_no_selector?("button#dropdown-menu-main-button"), "Dropdown button should not be visible"
        end

        test "main navigation dropdown sign out works correctly" do
          @dropdown.open

          # Click the sign out button
          click_button I18n.t("navigations.logged_in.main_nav.sign_out")

          # Assert that the user is logged out
          assert_current_path new_session_path(locale: I18n.locale)
          assert_text I18n.t("authentication.alerts.signed_out")
        end
      end
    end
  end
end
