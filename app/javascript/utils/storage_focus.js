// app/javascript/utils/storage_focus.js

export function storeFocus() {
  // https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset#name_conversion
  // Our 'chats--chat-list-target' converts to 'chats-ChatListTarget' which throws ReferenceError
  const focusedTarget = document.activeElement.getAttribute("data-chats--chat-list-target");
  const turboFrame = document.activeElement.closest("turbo-frame");

  if (focusedTarget && turboFrame) {
    sessionStorage.setItem(
      "chatFocus",
      JSON.stringify({
        frameId: turboFrame.id,
        target: focusedTarget,
      })
    );
  }
}

export function restoreFocus(rootElement = document, fallbackSelector = ".active-chat a") {
  // rootElement is the chats--chat-list element (or the document as fallback)
  // fallbackSelector is not passed, because this is the first usage of our function
  const chatFocusData = sessionStorage.getItem("chatFocus");
  let targetToFocus = rootElement.querySelector(fallbackSelector);

  if (chatFocusData) {
    try {
      const { frameId, target } = JSON.parse(chatFocusData);
      const chatTurboFrame = frameId && document.getElementById(frameId);

      if (chatTurboFrame && target) {
        // Our chat turbo-frame (chats__chat_list_target: "chatItem")
        // contains 3 tragets (linkToChat, editChatLink, deleteChat)
        const storedTarget = chatTurboFrame.querySelector(
          `[data-chats--chat-list-target="${target}"]`
        );
        if (storedTarget) targetToFocus = storedTarget;
      }
    } catch (e) {
      // We could log the error, but since this is for keyboard navigation only, I don't care ;)
    }
  }

  if (targetToFocus) {
    targetToFocus.focus();
    return true;
  }

  return false;
}
