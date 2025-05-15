import BaseController from "controllers/base_controller";

// Connects to data-controller="components--drawer"
export default class extends BaseController {
  // 1. Static Definitions
  static targets = ["dialog", "drawerButton"];
  static values = { open: Boolean };

  // 2. Lifecycle Methods
  // ----------------------
  connect() {
    super.connect(true);

    // Bind the private cancel event handler to capture the 'cancel' event (Escape key)
    this._handleCancel = this.#handleCancel.bind(this);
    this.dialogTarget.addEventListener("cancel", this._handleCancel);
  }

  disconnect() {
    this.dialogTarget.removeEventListener("cancel", this._handleCancel);
  }

  // 3. Target Lifecycle Methods (alphabetical)
  // ----------------------

  // 4a. Public Action Methods (alphabetical)
  // ----------------------
  backdropClose(event) {
    // If the click event's target is the dialog itself, close the drawer.
    if (event.target.nodeName === "DIALOG") {
      this.close();
    }
  }

  close() {
    /**
     * This is nice way to slide in the drawer. An inspiration I use from
     * https://github.com/excid3/tailwindcss-stimulus-components/blob/main/src/slideover.js
     * The closing attribute is used in conjunction with css - dialog.drawer-left[closing]
     */
    this.dialogTarget.setAttribute("closing", "");

    // Wait for all animations to finish before cleaning up and closing the dialog.
    Promise.all(this.dialogTarget.getAnimations().map((animation) => animation.finished)).then(
      () => {
        this.dialogTarget.removeAttribute("closing");

        // Hide from screen readers.
        this.dialogTarget.setAttribute("aria-hidden", "true");

        const event = this.dispatch("open", { detail: { open: false }, cancelable: true });
        // Not implemented 
        // If the event was canceled (via event.preventDefault()), we could do something here
        if (event.defaultPrevented) console.log("💜💜💜 event canceled ", event);

        this.dialogTarget.close();

        this.drawerButtonTarget.focus();

        // Restore scrolling
        document.body.classList.remove("overflow-hidden");
      }
    );
  }

  open() {
    // Use requestAnimationFrame to ensure the open animation is scheduled correctly.
    requestAnimationFrame(() => {
      this.dialogTarget.showModal();
      // Make it visible to screen readers.
      this.dialogTarget.setAttribute("aria-hidden", "false");
      // Prevent body scroll
      document.body.classList.add("overflow-hidden");

      console.log("dialog open");

      this.dispatch("open", { detail: { open: true } });
    });
  }

  // 4b. Public Dispatch Action Methods (alphabetical)
  // ----------------------

  // 5. Private Helper Methods (alphabetical)
  // ----------------------
  #handleCancel(event) {
    event.preventDefault();
    this.close();
  }
  
  // 6. Getters / Setters / Computed Properties (alphabetical)
  // ----------------------
}

/**
 * Informations about dialog
 *
 * https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dialog
 *
 */
