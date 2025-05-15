# frozen_string_literal: true

require "application_system_test_case"
require "test_helpers/system/drawer_helper"

module Stimulus
  module Components
    class DrawerTest < ApplicationSystemTestCase
      setup do
        @user = create(:user)
        sign_in(@user)
        @drawer = TestHelpers::System::DrawerHelper.new
      end

      test "Drawer opens when clicking the open drawer button" do
        @drawer.assert_drawer_hidden
        @drawer.open
        @drawer.assert_drawer_visible

        # We need to assert 'something' ;) to avoid 'Test is missing assertions:'
        assert_equal "drawer-title", @drawer.dialog_element[:'aria-labelledby'], "Expected aria-labelledby to be 'drawer-title'"
        assert_equal "drawer-description", @drawer.dialog_element[:'aria-describedby'], "Expected aria-describedby to be 'drawer-description'"
      end

      test "Drawer closes when clicking the close button inside the drawer" do
        @drawer.open
        @drawer.assert_drawer_visible
        @drawer.assert_and_close_by_button
        @drawer.assert_drawer_hidden

        # Verify focus returns to the drawer button.
        assert_selector("button[data-components--drawer-target='drawerButton']:focus", wait: 5)
      end

      test "Drawer closes when clicking on the backdrop" do
        @drawer.open
        @drawer.assert_drawer_visible
        @drawer.close_by_backdrop
        @drawer.assert_drawer_hidden

        # Verify focus returns to the drawer button.
        assert_selector("button[data-components--drawer-target='drawerButton']:focus", wait: 5)
      end

      test "Drawer closes when pressing escape" do
        @drawer.open
        @drawer.assert_drawer_visible
        @drawer.close_by_escape
        @drawer.assert_drawer_hidden

        # Verify focus returns to the drawer button.
        assert_selector("button[data-components--drawer-target='drawerButton']:focus", wait: 5)
      end
    end
  end
end
