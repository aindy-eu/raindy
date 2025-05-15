import BaseController from "controllers/base_controller";

// Connects to data-controller="chats--chat-edit"
export default class extends BaseController {
  // 1. Static Definitions
  static targets = ["cancelEditButton", "submitEditFormButton", "chatNameInput"];

  // 2. Lifecycle Methods
  // ----------------------
  connect() {
    // Show controller name
    super.connect(true);

    this.shiftTab = false;
    this.formSubmitted = false;
    this.canceled = false;
  }

  // 3. Target Lifecycle Methods (alphabetical)
  // ----------------------
  chatNameInputTargetConnected(element) {
    // No autofocus for iOS Safari ;) - https://bugs.webkit.org/show_bug.cgi?id=195884#c4
    const length = element.value.length;
    element.setSelectionRange(length, length);
  }

  // 4a. Public Action Methods (alphabetical)
  // ----------------------

  // Action bound to the controller (keydown.esc)
  cancelEdit() {
    console.log("cancelEdit 🩷");
    this.canceled = true;
    this.cancelEditButtonTarget.click();
  }

  // Action bound to the controller (keydown.shift)
  // This implementation was created before I discovered, that shift+tab is possible
  // It works, but we should refactor this in another user story (TODO ;)
  detectShiftTab(event) {
    if (event.key === "Tab") {
      console.log("detectShiftTab triggered 🩵");
      this.shiftTab = true;
      this.submitEditForm();
    }
  }

  // Action bound to the controller (keydown.tab)
  // We use keydown here, to immediately submit and leave the form 
  detectTab() {
    console.log("detectTab triggered 💙");
    this.submitEditForm();
  }

  // Action bound to the name input field (blur)
  // Prevent double submission
  leaveInputField() {
    if (!this.canceled && !this.formSubmitted) {
      console.log("leaveInputField will 💚 submitEditForm");
      this.submitEditForm();
    }
  }

  // Action bound to the submit button (click & enter)
  submitEditForm() {
    if (this.#nameValueNotChanged()) {
      this.cancelEdit();
    } else {
      this.element.requestSubmit();
      this.formSubmitted = true;
      console.log("submitEditForm 💚💚 submitted");
    }

    this.dispatch("chatEditFinished", { detail: { usedShiftTab: this.shiftTab } });
    this.shiftTab = false;
  }

  // 4b. Public Dispatch Action Methods (alphabetical)
  // ----------------------

  // 5. Private Helper Methods (alphabetical)
  // ----------------------
  #nameValueNotChanged() {
    const chatNameInput = this.chatNameInputTarget;
    console.log("chat name current value 💛 ", chatNameInput.dataset.currentValue);
    console.log("chat name new value      🧡 ", chatNameInput.value);
    return chatNameInput.value === chatNameInput.dataset.currentValue;
  }
  
  // 6. Getters / Setters / Computed Properties (alphabetical)
  // ----------------------
}
