<!--
---
title: "Stimulus Guidelines"
description: "Conventions for organizing and implementing Stimulus controllers"
updated: "2025-05-15 10:21:00"
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
tags: ["stimulus", "javascript", "controllers", "frontend"]
related_docs:
  - path: "/app/javascript/controllers/base_controller.js"
  - path: "/app/javascript/controllers/chats/chat_list_controller.js"
  - path: "/app/javascript/controllers/components/dropdown_controller.js"
  - path: "/app/javascript/controllers/components/alert_controller.js"
  - path: "/app/javascript/utils/storage_focus.js"
  - path: "/app/javascript/controllers/application.js"
  - path: "/app/javascript/controllers/index.js"
  - path: "/docs/architecture/stimulus-component-guidelines.md"
  - path: "/docs/architecture/stimulus-dispatch-guidelines.md"
  - path: "/docs/architecture/technical-overview.md"
  - path: "/docs/architecture/README.md"
  - path: "/docs/testing/stimulus-testing-guidelines.md"
---
-->

# Stimulus Guidelines

This guide outlines high-level conventions for using Stimulus in this Rails 8 chat application, covering controller organization, shared logic, accessibility, and debugging. It targets intermediate developers familiar with Hotwire. For UI component patterns, see `docs/architecture/stimulus-component-guidelines.md`. For cross-controller communication, see `docs/architecture/stimulus-dispatch-guidelines.md`.

## Table of Contents
- [Stimulus Guidelines](#stimulus-guidelines)
  - [Table of Contents](#table-of-contents)
  - [1. Overview](#1-overview)
  - [2. Controller Organization](#2-controller-organization)
    - [Controller Registration](#controller-registration)
    - [Global Utilities: `utils/`](#global-utilities-utils)
  - [3. BaseController](#3-basecontroller)
  - [3.1 Standard Controller Structure](#31-standard-controller-structure)
  - [4. Cross-Controller Communication (Dispatch)](#4-cross-controller-communication-dispatch)
  - [5. Accessibility](#5-accessibility)
  - [6. Debugging](#6-debugging)
  - [7. Related Resources](#7-related-resources)

## 1. Overview

Stimulus adds modular, unobtrusive interactivity to the application, enhancing Turbo-driven UI with lightweight JavaScript. Controllers manage specific behaviors for domains (e.g., `chats--chat-list`), UI components (e.g., `components--dropdown`), app-wide logic (e.g., `app--pwa`), or debugging (e.g., `debug--turbo-listener`). They extend `BaseController` for shared debugging and use event dispatching for coordination, ensuring loose coupling.

Example: `app/javascript/controllers/chats/chat_list_controller.js` handles chat list interactions.

## 2. Controller Organization

Stimulus controllers reside in `app/javascript/controllers/`, organized by function:

```
app/javascript/controllers/
  app/         # App-wide logic (e.g., pwa_controller.js)
  chats/       # Chat-specific logic (e.g., chat_list_controller.js)
  components/  # UI components (e.g., dropdown_controller.js)
  debug/       # Debugging tools (e.g., turbo_listener_controller.js)
  helpers/     # Shared logic (e.g., application_controller.js)
  application.js  # Stimulus setup
  base_controller.js  # Base class
  index.js     # Auto-registration
```

**Naming**:
- Format: `domain--controller-name` (e.g., `chats--chat-list`).
- File: `app/javascript/controllers/domain/controller_name_controller.js`.
- HTML: `<div data-controller="chats--chat-list">`.

### Controller Registration

In this project, we use Rails 8's automatic controller registration system. The `index.js` file handles this through `eagerLoadControllersFrom`:

```js
// app/javascript/controllers/index.js
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
```

⚠️ **DO NOT manually register controllers** by adding imports and explicit registrations to `index.js`:

```js
// INCORRECT - Do not do this!
import SomeController from "./path/to/some_controller"
application.register("some", SomeController)
```

**Rules**:
- Place controllers in subdirectories (e.g., `components/`).
- Use `_controller.js` suffix (e.g., `dropdown_controller.js`).
- Match HTML `data-controller` (e.g., `data-controller="components--alert"`).
- Avoid manual registration (e.g., `application.register("some", SomeController)`).


### Global Utilities: `utils/`

Utility modules that support controller behavior — like focus handling or storage helpers — live outside `controllers/` in `utils/` and are imported into controllers via importmap:

```js
import { storeFocus, restoreFocus } from "utils/storage_focus";
```

They help keep controller logic clean, reusable, and focused on UI behavior.


## 3. BaseController

All controllers extend `BaseController`, which includes:

**Usage**:
- `super.connect(true)` enables debug logging (e.g., `chat_list_controller.js`).
- Logs controller names in non-production environments.

Example:
```js
// app/javascript/controllers/components/dropdown_controller.js
import BaseController from "controllers/base_controller";

export default class extends BaseController {
  connect() {
    super.connect(false); // No debug logging
  }
}
```

## 3.1 Standard Controller Structure

> [!IMPORTANT]
> All controllers should follow the same structural pattern defined in [Stimulus Component Guidelines - Controller Structure](/docs/architecture/stimulus-component-guidelines.md#3-controller-structure), not just component controllers.

Every controller should use this structure:

```js
import BaseController from "controllers/base_controller";

// Connects to data-controller="namespace--name"
export default class extends BaseController {
  // 1. Static Definitions
  static targets = ["targetName"];
  static values = { valueName: String };

  // 2. Lifecycle Methods
  // ----------------------
  connect() {
    super.connect(true); // Set to true to enable debug logging
    // Initialization logic
  }

  disconnect() {
    // Cleanup logic
  }

  // 3. Target Lifecycle Methods (alphabetical)
  // ----------------------
  targetNameTargetConnected() {
    // Logic when target connects
  }

  // 4a. Public Action Methods (alphabetical)
  // ----------------------
  someAction() {
    // Public method implementation
  }

  // 4b. Public Dispatch Action Methods (alphabetical)
  // ----------------------
  dispatchAction(event, detail) {
    // Dispatch-related logic
  }

  // 5. Private Helper Methods (alphabetical)
  // ----------------------
  #privateHelper() {
    // Private method implementation
  }
  
  // 6. Getters / Setters / Computed Properties (alphabetical)
  // ----------------------
  get someProperty() {
    return this.someCalculatedValue;
  }
}
```

## 4. Cross-Controller Communication (Dispatch)

See [Stimulus Dispatch Guidelines](/docs/architecture/stimulus-dispatch-guidelines.md) for examples and usage patterns.


## 5. Accessibility

Stimulus controllers prioritize accessibility with ARIA attributes and focus management:
- **ARIA Attributes**: `chat_list_controller.js` uses `aria-current` for active chats, `dropdown_controller.js` uses `aria-expanded` for menus.
- **Focus Management**: `storage_focus.js` saves/restores focus for keyboard navigation (e.g., `chat_list_controller.js`'s `tabKeyPressed`).
- **Keyboard Navigation**: `dropdown_controller.js` handles `keydown.up/down` for menu navigation.


## 6. Debugging

**Turbo Debugger**: 
In `application.html.erb`, `<div data-controller="debug--turbo-listener"></div>` enables:
- `debug--turbo-listener` logs Turbo events in grouped fashion
- `debugEventEnabled` toggles full event logs
- `debugEventDetailEnabled` toggles `event.detail` dumps


## 7. Related Resources
- **Code**:
  - [Base Controller](/app/javascript/controllers/base_controller.js)
  - [Chat List Controller](/app/javascript/controllers/chats/chat_list_controller.js)
  - [Dropdown Controller](/app/javascript/controllers/components/dropdown_controller.js)
  - [Alert Controller](/app/javascript/controllers/components/alert_controller.js)
  - [Storage Focus Utility](/app/javascript/utils/storage_focus.js)
  - [Application Setup](/app/javascript/controllers/application.js)
  - [Controller Index](/app/javascript/controllers/index.js)
- **Guidelines**:
  - [Stimulus Component Guidelines](/docs/architecture/stimulus-component-guidelines.md)
  - [Stimulus Dispatch Guidelines](/docs/architecture/stimulus-dispatch-guidelines.md)
  - [Technical Overview](/docs/architecture/technical-overview.md)
  - [Architecture Overview](/docs/architecture/README.md)
  - [Stimulus Testing Guidelines](/docs/testing/stimulus-testing-guidelines.md)
- **External**:
  - [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
  - [Stimulus Reference](https://stimulus.hotwired.dev/reference/controllers)
  - [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

---

Let's **Stimulate** Beautifully! 🩵
