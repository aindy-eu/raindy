import BaseController from "controllers/base_controller";

// Added in importmap.rb - pin_all_from "app/javascript/utils", under: "utils"
import { storeFocus, restoreFocus } from "utils/storage_focus";

// Connects to data-controller="chats--chat-list"
export default class extends BaseController {
  // 1. Static Definitions
  static targets = ["chatItem", "editChatLink", "linkToChat", "deleteChat"];
  static values = {
    editChat: { type: Boolean, default: false },
    chatEditFinished: { type: Boolean, default: false },
  };

  // 2. Lifecycle Methods
  // ----------------------
  connect() {
    // Show controller name
    super.connect(true);

    // Listen for the key event from the edit controller
    // There is an easier way to handle a dispatch
    // like the components--drawer:open implementation (TODO ;)
    // https://stimulus.hotwired.dev/reference/controllers#cross-controller-coordination-with-events
    this.chatEditFinishedHandler = this.#handleChatEditFinished.bind(this);
    this.element.addEventListener("chats--chat-edit:chatEditFinished", this.chatEditFinishedHandler);

    // Our #currentChatId is a get method, so no ()
    this.currentChatId = this.#currentChatId;
    this.#highlightCurrentChat();
  }

  disconnect() {
    // Clean up event listener
    this.element.removeEventListener("chats--chat-edit:chatEditFinished", this.chatEditFinishedHandler);
  }

  // 3. Target Lifecycle Methods (alphabetical)
  // ----------------------
  editChatLinkTargetConnected(element) {
    console.log("editChatLinkTargetConnected 🤍");

    if (this.editChatValue) {
      // Adds a delay to prevent the delete chat buttons from being re-enabled during chat editing.
      // Without this, a Turbo update (triggered by blur/form submission) replaces the turbo-frame
      // so quickly that #toggleChatActions incorrectly enables all delete buttons.
      setTimeout(() => {
        this.#toggleNewChatForm(false);
        this.#toggleChatActions(false);
      }, 300);

      if (this.chatEditFinishedValue) {
        this.#focusChatDetailLink(element);
      } else {
        this.#focusEditChatLink(element);
      }

      this.#highlightCurrentChat();
    }
  }

  // 4a. Public Action Methods (alphabetical)
  // ----------------------

  // Action bound to the delete chat button (click & enter)
  deleteChat(event) {
    const nextTurboFrame = event.target.closest("turbo-frame").nextElementSibling;
    if (nextTurboFrame) {
      const detailLink = nextTurboFrame.querySelector("a");
      if (detailLink) detailLink.focus();
    }
  }

  // Action bound to the edit chat button (click & enter)
  editChat() {
    this.editChatValue = true;
    this.#toggleNewChatForm(true);
    this.#toggleChatActions(true);
  }

  // Action bound to this controller (keyup.shift+tab)
  //
  // Nice to know - keyup.shift doesn't exists and doesn't trigger this function
  // If I press shift and then tab the keyup.tab is catched here - Interesting ...
  // But since shift is 1 of 4 'modifier keys' we us shift+tab to be more decribing
  // https://stimulus.hotwired.dev/reference/actions#keyboardevent-filter
  shiftTabKeyPressed(event) {
    console.log(`🩵 shiftTabKeyPressed: ${event.key} | ${event.type}`);
    this.#storeFocus();
  }

  // Action bound to this controller (keyup.tab)
  tabKeyPressed(event) {
    console.log(`🧡 tabKeyPressed: ${event.key} | ${event.type}`);
    this.#storeFocus();
  }

  // 4b. Public Dispatch Action Methods (alphabetical)
  // ----------------------

  // Action bound to this controller, that get dispatch
  // components--drawer:open@window->chats--chat-list#openDrawer
  openDrawer({ detail: { open } }) {
    console.log("disptached 'open' - openDrawer 💜 ", open);
    if (open) {
      this.#restoreFocus();
    } else {
      this.#storeFocus();
    }
  }

  // 5. Private Helper Methods (alphabetical)
  // ----------------------

  // I am using 'get' here, because it is more readable
  // and the () are at least for me not needed ;)
  get #currentChatId() {
    const path = window.location.pathname;
    const match = path.match(/^\/chats\/([\w-]+)/);
    return match ? match[1] : null;
  }

  #focusEditChatLink(element) {
    element.focus();
    this.#storeFocus();
    this.editChatValue = false;
    this.chatEditFinishedValue = false;
  }

  #focusChatDetailLink(element) {
    const chatItems = element.closest(".chat-items");
    if (chatItems) {
      const detailLink = chatItems.firstElementChild;
      if (detailLink) {
        detailLink.focus();
        this.#storeFocus();
        this.editChatValue = false;
        this.chatEditFinishedValue = false;
      }
    }
  }

  #handleChatEditFinished(event) {
    console.log("handleChatEditFinished ❤️❤️ usedShiftTab: ", event.detail.usedShiftTab);
    this.chatEditFinishedValue = event?.detail?.usedShiftTab || false;
  }

  #highlightCurrentChat() {
    if (!this.currentChatId) return;

    this.chatItemTargets.forEach((el) => {
      // The abbr. 'el' is only used in loops
      // Otherwise 'this.element' or 'element' should be favored
      if (el.id === `chat_${this.currentChatId}`) {
        el.classList.add("active-chat");
        el.querySelector("a")?.setAttribute("aria-current", "page");
      } else {
        el.classList.remove("active-chat");
        el.querySelector("a")?.removeAttribute("aria-current");
      }
    });
  }

  // I am using 'utils' here, the controller doesn't have to deal with session storage.
  #restoreFocus() {
    restoreFocus(this.element);
  }

  #storeFocus() {
    storeFocus();
  }

  #toggleChatActions(disable) {
    const chatItems = this.chatItemTargets;
    chatItems.forEach((chatItem) => {
      chatItem.querySelectorAll(".chat-items").forEach((el) => {
        disable
          ? el.classList.add("cursor-not-allowed")
          : el.classList.remove("cursor-not-allowed");
      });
      chatItem.querySelectorAll(".chat-items a, .chat-items button").forEach((el) => {
        disable ? el.setAttribute("aria-disabled", "true") : el.removeAttribute("aria-disabled");
      });
      chatItem.querySelectorAll("button").forEach((el) => {
        el.disabled = disable;
      });
    });
  }

  #toggleNewChatForm(disable) {
    const form = document.getElementById("chats_new_form_new");
    // Since 'aria-disabled' is optional for buttons, I waive it here ;)
    if (form) form.querySelectorAll("input, button").forEach((el) => (el.disabled = disable));
  }
  
  // 6. Getters / Setters / Computed Properties (alphabetical)
  // ----------------------
}
