---
title: "Stimulus Dispatch Guidelines"
description: "Guidelines for cross-controller communication using dispatch in Stimulus"
updated: "2025-05-15 10:20:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: xai-grok-3
    ai: true
  - username: cursor-anthropic-claude-3-7-sonnet
    ai: true
  - username: cursor-gpt-4-1
    ai: true
pillar: "Architecture"
tags: ["stimulus", "dispatch", "controllers"]
related_docs:
  - path: "/app/javascript/controllers/components/drawer_controller.js"
  - path: "/app/javascript/controllers/chats/chat_list_controller.js"
  - path: "/app/javascript/controllers/components/clipboard_controller.js"
  - path: "/app/javascript/controllers/components/effects_controller.js"
  - path: "/docs/architecture/README.md"
  - path: "/docs/architecture/stimulus-guidelines.md"
  - path: "/docs/architecture/stimulus-component-guidelines.md"
  - path: "/docs/architecture/technical-overview.md"
  - path: "/docs/testing/stimulus-testing-guidelines.md"
---

# Stimulus Dispatch Guidelines

This document outlines how cross-controller communication is handled using `this.dispatch()` in Stimulus. 
It follows the official Stimulus approach and adapts it to the componentized structure used in this project.

## Table of Contents
- [Stimulus Dispatch Guidelines](#stimulus-dispatch-guidelines)
  - [Table of Contents](#table-of-contents)
  - [1. Why Dispatch?](#1-why-dispatch)
  - [2. Basic Example: Local Dispatch](#2-basic-example-local-dispatch)
  - [3. Global Dispatch via `@window`](#3-global-dispatch-via-window)
  - [4. Real-World Component Dispatch Example](#4-real-world-component-dispatch-example)
    - [Emitting Controller](#emitting-controller)
    - [Listener Controller](#listener-controller)
    - [HTML Setup](#html-setup)
  - [5. Using dispatch() options](#5-using-dispatch-options)
    - [Example: prevent default on cancelable event](#example-prevent-default-on-cancelable-event)
  - [6. Tips](#6-tips)
  - [7. Related Resources](#7-related-resources)

## 1. Why Dispatch?

Stimulus encourages communication via **events**, not direct controller references.

We use `this.dispatch()` to trigger events and respond to them from other controllers 
— optionally across the DOM using `@window`.

This keeps controllers **decoupled**, **testable**, and **reusable**.


## 2. Basic Example: Local Dispatch

When both controllers are mounted on the **same DOM element**:

```js
// controllers/components/clipboard_controller.js
export default class extends Controller {
  static targets = ["source"];

  copy() {
    this.dispatch("copy", {
      detail: { content: this.sourceTarget.value }
    });

    navigator.clipboard.writeText(this.sourceTarget.value);
  }
}
```

```html
<div data-controller="components--clipboard components--effects"
     data-action="components--clipboard:copy->components--effects#flash">
  <input data-components--clipboard-target="source" value="123">
  <button data-action="components--clipboard#copy">Copy</button>
</div>
```

```js
// controllers/components/effects_controller.js
export default class extends Controller {
  flash({ detail: { content } }) {
    console.log("🩵 Received clipboard content:", content);
  }
}
```


## 3. Global Dispatch via `@window`

When controllers are not on the same DOM element or are distant in the DOM tree, 
add `@window` to the `data-action`:

```html
<div data-controller="components--clipboard">
  <input data-components--clipboard-target="source" value="123">
  <button data-action="components--clipboard#copy">Copy</button>
</div>

<div data-controller="components--effects"
     data-action="components--clipboard:copy@window->components--effects#flash">
</div>
```


## 4. Real-World Component Dispatch Example

In this project, the `components--drawer` controller dispatches an event to signal its open/close state.
The `chats--chat-list` controller listens for this global event and responds accordingly.

### Emitting Controller

```js
// controllers/components/drawer_controller.js
this.dispatch("open", { detail: { open: true } });
```

### Listener Controller

```js
// controllers/chats/chat_list_controller.js
openDrawer({ detail: { open } }) {
  console.log("Received open event for drawer:", open);
  if (open) this.#restoreFocus();
}
```

### HTML Setup

```html
<div data-controller="chats--chat-list"
     data-action="components--drawer:open@window->chats--chat-list#openDrawer">
</div>
```

This pattern allows the drawer to **emit state changes** without requiring any knowledge of who is listening.


## 5. Using dispatch() options

You can configure event behavior with options:

| Option       | Default               | Description                                              |
| ------------ | --------------------- | -------------------------------------------------------- |
| `detail`     | `{}`                  | Data passed to the event                                 |
| `target`     | `this.element`        | Element to dispatch from                                 |
| `prefix`     | controller identifier | Controls event name prefixing (not used in this project) |
| `bubbles`    | `true`                | Enables bubbling through DOM                             |
| `cancelable` | `true`                | Allows other listeners to cancel the event               |

### Example: prevent default on cancelable event

```js
const event = this.dispatch("open", { cancelable: true });
if (event.defaultPrevented) return;

// Continue with default logic
```

```js
openDrawer(event) {
  event.preventDefault(); // cancel default behavior
}
```


## 6. Tips

- In your controller, clearly document which events this method responds to. Place it under `4b. Public Dispatch Action Methods` with consistent comments.

```js
  // 4b. Public Dispatch Action Methods
  // ----------------------

  // Action bound to this controller, that gets dispatched
  // components--drawer:open@window->chats--chat-list#openDrawer
  openDrawer({ detail: { open } }) {
    // Implementation
  }
```


## 7. Related Resources
- **Code**:
  - [Drawer Controller](/app/javascript/controllers/components/drawer_controller.js)
  - [Chat List Controller](/app/javascript/controllers/chats/chat_list_controller.js)
  - [Clipboard Controller](/app/javascript/controllers/components/clipboard_controller.js)
  - [Effects Controller](/app/javascript/controllers/components/effects_controller.js)
- **Guidelines**:
  - [Stimulus Guidelines](/docs/architecture/stimulus-guidelines.md)
  - [Stimulus Component Guidelines](/docs/architecture/stimulus-component-guidelines.md)
  - [Technical Overview](/docs/architecture/technical-overview.md)
  - [Stimulus Testing Guidelines](/docs/testing/stimulus-testing-guidelines.md)
  - [Architecture Overview](/docs/architecture/README.md)
  - [Turbo Guidelines](/docs/architecture/turbo-guidelines.md)
- **External**:
  - [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
  - [Stimulus Reference](https://stimulus.hotwired.dev/reference/controllers)
  - [Stimulus Dispatch Reference](https://stimulus.hotwired.dev/reference/controllers#cross-controller-coordination-with-events)
  - [Events Documentation](https://developer.mozilla.org/en-US/docs/Web/Events)

---

Let's **Dispatch** Beautifully! 🩵
