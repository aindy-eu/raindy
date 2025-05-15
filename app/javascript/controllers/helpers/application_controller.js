import BaseController from "controllers/base_controller";

// Connects to data-controller="helpers--application"
export default class extends BaseController {
  // 1. Static Definitions
  // (No static targets/values for now)

  // 2. Lifecycle Methods
  // ----------------------
  connect() {
    super.connect(false);

    // Bind the visibility change handler to maintain correct context.
    this._handleVisibilityChange = this.#checkServerHealth.bind(this);
    document.addEventListener("visibilitychange", this._handleVisibilityChange);

    /**
     * Avoid binding inline when adding the event listener. For example:
     *
     *   document.addEventListener("visibilitychange", this.#checkServerHealth.bind(this));
     *
     * This is problematic because each call to .bind(this) creates a new function instance.
     * As a result, if you try to remove the event listener later using the same inline code,
     * it won't work since the reference is different.
     *
     * Instead, bind once and store the function reference:
     *
     *   this._handleVisibilityChange = this.#checkServerHealth.bind(this);
     *   document.addEventListener("visibilitychange", this._handleVisibilityChange);
     */
  }

  disconnect() {
    // Remove the bound event handler to prevent memory leaks.
    document.removeEventListener("visibilitychange", this._handleVisibilityChange);
  }

  // 3. Target Lifecycle Methods (alphabetical)
  // ----------------------

  // 4a. Public Action Methods (alphabetical)
  // ----------------------
  reloadApp() {
    location.reload();
  }

  // 4b. Public Dispatch Action Methods (alphabetical)
  // ----------------------

  // 5. Private Helper Methods (alphabetical)
  // ----------------------
  async #checkServerHealth() {
    if (document.visibilityState === "visible") {
      console.log("User returned to the app, checking server health...");
      try {
        const response = await fetch("/up", { method: "GET", credentials: "same-origin" });
        if (!response.ok) {
          console.warn("Server health check failed:", response.status);
          this.#showServerDownPrompt(response.status);
        }
      } catch (error) {
        console.error("Health check request failed:", error);
        this.#showServerDownPrompt(error);
      }
    }
  }

  #showServerDownPrompt(error) {
    // Concatenate error into the message for clarity.
    alert("Sorry ;) Der Server / mein MacBook ist gerade nicht erreichbar. Fehler: " + error);
  }
  
  // 6. Getters / Setters / Computed Properties (alphabetical)
  // ----------------------
}
