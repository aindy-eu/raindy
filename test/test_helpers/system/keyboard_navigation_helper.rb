# frozen_string_literal: true

module KeyboardNavigationHelper
  # Focuses the element matching the selector by sending TABs until it's focused.
  # Optionally, you can pass a max number of tabs to avoid infinite loops.
  def focus_element_with_tab(selector, max_tabs: 20)
    # Ensure the element exists before attempting to focus
    find(selector, visible: true, wait: 5)

    tabs_sent = 0
    until has_selector?("#{selector}:focus", wait: 0)
      find("body").send_keys(:tab)
      sleep 0.2
      tabs_sent += 1
      raise "Could not focus #{selector} after #{max_tabs} tabs" if tabs_sent >= max_tabs
    end
  end
end
