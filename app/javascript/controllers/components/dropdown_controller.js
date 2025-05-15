import BaseController from "controllers/base_controller";

// Connects to data-controller="components--dropdown"
export default class extends BaseController {
  // 1. Static Definitions
  static targets = ["menu", "menuItem", "menuButton"]

  // 2. Lifecycle Methods
  // ----------------------
  connect() {
    super.connect(false)

    // Bind 'this' to maintain context for this.element
    this._handleOutsideClick = this.#handleOutsideClick.bind(this)
    document.addEventListener("click", this._handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this._handleOutsideClick)
  }

  // 3. Target Lifecycle Methods (alphabetical)
  // ----------------------

  // 4a. Public Action Methods (alphabetical)
  // ----------------------
  // Menu Close (keydown.esc)
  closeMenu() {
    // Hide menu visually
    this.menuTarget.hidden = true
    this.menuTarget.classList.add("hidden")

    // Update ARIA
    this.menuButtonTarget.setAttribute("aria-expanded", "false")

    // Return focus to the button
    this.menuButtonTarget.focus()
  }

  // Arrow Navigation (keydown.up and keydown.left)
  focusPreviousItem() {
    const currentIndex = this.menuItemTargets.indexOf(document.activeElement)
    let prevIndex = currentIndex - 1
    if (prevIndex < 0) {
      prevIndex = this.menuItemTargets.length - 1
    }
    this.menuItemTargets[prevIndex].focus()
  }

  // Arrow Navigation (keydown.down and keydown.right)
  focusNextItem() {
    const currentIndex = this.menuItemTargets.indexOf(document.activeElement)
    let nextIndex = currentIndex + 1
    if (nextIndex >= this.menuItemTargets.length) {
      nextIndex = 0
    }
    this.menuItemTargets[nextIndex].focus()
  }

  toggle(event) {
    // prevent immediate close on same click
    event.stopPropagation()
    if (this.#isOpen) {
      this.closeMenu()
    } else {
      this.#openMenu()
    }
  }

  // 4b. Public Dispatch Action Methods (alphabetical)
  // ----------------------

  // 5. Private Helper Methods (alphabetical)
  // ----------------------
  #handleOutsideClick(event) {
    if (!this.#isOpen) return;

    // If user clicks anywhere outside the dropdown, close it
    if (!this.element.contains(event.target)) {
      this.closeMenu()
    }
  }

  #openMenu() {
    // Show menu visually
    this.menuTarget.hidden = false
    this.menuTarget.classList.remove("hidden")

    // Update ARIA
    this.menuButtonTarget.setAttribute("aria-expanded", "true")

    // Move focus to the first menu item
    if (this.menuItemTargets.length > 0) {
      this.menuItemTargets[0].focus()
    }
  }

  // 6. Getters / Setters / Computed Properties (alphabetical)
  // ----------------------
  get #isOpen() {
    return this.menuButtonTarget.getAttribute("aria-expanded") === "true"
  }
}

/**
 * How to use a dropdown based on the menubar pattern
 * 
 * https://www.w3.org/WAI/ARIA/apg/patterns/menubar/ 
 * https://www.w3.org/WAI/tutorials/menus/flyout/
 * https://www.w3.org/WAI/ARIA/apg/patterns/menubar/examples/menubar-navigation/
 * 
 * https://216digital.com/web-accessibility-making-drop-down-menus-user-friendly/
 * 
 */ 
