import BaseController from "controllers/base_controller";
import { Turbo } from "@hotwired/turbo-rails"

// Connects to data-controller="helpers--flash"
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

  // 4b. Public Dispatch Action Methods (alphabetical)
  // ----------------------
  flash({ detail: { content, error } }) {
    if (error) {
      console.log("💚 Received error from clipboard controller:", error);
      this.#fallbackFlashAlert("alert", `Failed to copy "${content}": ${error}`);
    } else {
      console.log("💚 Revieved copied content:", content);
      this.#sendFlash("success", `${content} - copied to the clipboard`);
    }
  }

  // 5. Private Helper Methods (alphabetical)
  // ----------------------
  #fallbackFlashAlert(type, message) {
    const colors = {
      success: "bg-green-100 text-green-700",
      alert: "bg-red-100 text-red-700",
      notice: "bg-blue-100 text-blue-700",
      warning: "bg-amber-100 text-amber-700"
    };

    return `
      <turbo-stream action="append" target="flash_messages">
        <template>
          <div id="alert-${type}-${Date.now()}"
               class="alert ${colors[type] || colors.notice} transition-opacity duration-300"
               role="alert"
               data-controller="components--alert"
               data-components--alert-delay-value="8000">
            <span data-components--alert-target="message">
              ${message}
            </span>
            <button name="button"
                    type="button"
                    tabindex="0"
                    class="px-4 py-1.5 bg-transparent hover:bg-white text-2xl rounded-lg cursor-pointer focus:inset-ring-2 focus:inset-ring-violet-500 focus:outline-hidden"
                    data-components--alert-target="closeButton"
                    data-action="click->components--alert#close"
                    aria-label="Close">
              ×
            </button>
          </div>
        </template>
      </turbo-stream>
    `;
  }

  async #sendFlash(type, message) {
    const token = document.querySelector("meta[name=csrf-token]").content;

    if (!token) {
      console.error("CSRF token not found");
      this.#fallbackFlashAlert("alert", "CSRF token missing");
      return;
    }

    try {
      const response = await fetch("/flash_message", {
        method: "POST",
        body: JSON.stringify({ flash: { [type]: message } }),
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": token,
        },
        credentials: "same-origin",
      });

      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
      }

      const html = await response.text();
      console.log("Turbo Stream response 💙:", html);
      Turbo.renderStreamMessage(html);

    } catch (error) {
      Turbo.renderStreamMessage(
        this.#fallbackFlashAlert("alert", `An error occurred: ${error.message}`)
      );
    }
  }

  // 6. Getters / Setters / Computed Properties (alphabetical)
  // ----------------------
}