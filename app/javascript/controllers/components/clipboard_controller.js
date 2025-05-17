import BaseController from "controllers/base_controller";

// Connects to data-controller="components--clipboard"
export default class extends BaseController {
  // 1. Static Definitions
  // (No static targets/values for now)

  // 2. Lifecycle Methods
  // ----------------------
  connect() {
    super.connect(true)
  }

  // 3. Target Lifecycle Methods (alphabetical)
  // ----------------------

  // 4a. Public Action Methods (alphabetical)
  // ----------------------
  async copy(event) {
    const content = event.target.closest("button").dataset.clipboardText;
  
    console.log("🤍🤍 data-clipboard-text:", content);
  
    try {
      await navigator.clipboard.writeText(content);
      this.dispatch("copy", { detail: { content } });
    } catch (error) {
      console.error("Clipboard error:", error);
      this.dispatch("copy", { detail: { content, error: error.message } });
    }
  }

  // 4b. Public Dispatch Action Methods (alphabetical)
  // ----------------------

  // 5. Private Helper Methods (alphabetical)
  // ----------------------

  // 6. Getters / Setters / Computed Properties (alphabetical)
  // ----------------------
}