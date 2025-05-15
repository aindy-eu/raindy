import BaseController from "controllers/base_controller";

// Connects to data-controller="components--alert"
// Expects a delay value from flash_alert (via data-components--alert-delay-value),
// set by Constants::ALERT_DEFAULT_DELAY or Constants::ALERT_TEST_DELAY in Ruby.
export default class extends BaseController {
  // 1. Static Definitions
  static targets = ["message", "closeButton"];
  static values = {
    delay: Number
  };

  // 2. Lifecycle Methods
  // ----------------------
  connect() {
    // Show controller name
    super.connect(true);
    
    if (this.#validateDelay()) {
      this.#announceToScreenReader();
      this.#startAutoDismiss();
    }
  }

  disconnect() {
    this.#clearAutoDismiss();
  }

  // 3. Target Lifecycle Methods (alphabetical)
  // ----------------------
  messageTargetConnected() {
    this.#announceToScreenReader();
  }

  // 4a. Public Action Methods (alphabetical)
  // ----------------------
  close() {    
    this.element.remove();
  }

  // 4b. Public Dispatch Action Methods (alphabetical)
  // ----------------------

  // 5. Private Helper Methods (alphabetical)
  // ----------------------
  #announceToScreenReader() {
    if (this.hasMessageTarget) {
      const liveRegion = document.createElement("div");
      liveRegion.setAttribute("aria-live", "polite");
      liveRegion.setAttribute("class", "sr-only");
      liveRegion.textContent = this.messageTarget.textContent;
      document.body.appendChild(liveRegion);
      setTimeout(() => liveRegion.remove(), 1000); // Clean up after announcement
    }
  }

  #clearAutoDismiss() {
    if (this.timeout) {
      clearTimeout(this.timeout);
      this.timeout = null;
    }
  }

  #startAutoDismiss() {
    this.#clearAutoDismiss(); // Ensure no duplicate timeouts
    this.timeout = setTimeout(() => this.close(), this.delayValue);
  }

  #validateDelay() {
    if (!this.hasDelayValue || this.delayValue <= 0) {
      if (this._shouldLog) {
        console.warn(
          `${this.controllerName}: Invalid or missing delay value (${this.delayValue}); ` +
          `expected positive number from flash_alert (Constants::ALERT_DEFAULT_DELAY or Constants::ALERT_TEST_DELAY). ` +
          `Auto-dismissal disabled.`
        );
      }
      return false;
    }
    return true;
  }
  
  // 6. Getters / Setters / Computed Properties (alphabetical)
  // ----------------------
}