---
title: "Stimulus Component Guidelines"
description: "Patterns and practices for creating and using Stimulus components"
updated: "2025-05-15 10:18:00"
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
tags: ["stimulus", "javascript", "architecture"]
related_docs:
  - path: "/app/javascript/controllers/components/drawer_controller.js"
  - path: "/app/javascript/controllers/components/dropdown_controller.js"
  - path: "/app/javascript/controllers/components/alert_controller.js"
  - path: "/app/javascript/controllers/base_controller.js"
  - path: "/app/views/shared/_drawer.html.erb"
  - path: "/app/views/shared/_flash.html.erb"
  - path: "/docs/architecture/stimulus-guidelines.md"
  - path: "/docs/architecture/stimulus-dispatch-guidelines.md"
  - path: "/docs/architecture/technical-overview.md"
  - path: "/docs/architecture/README.md"
  - path: "/docs/testing/stimulus-testing-guidelines.md"
---

# Stimulus Component Guidelines

This guide defines patterns for creating reusable Stimulus components (e.g., drawers, dropdowns, alerts) in this Rails 8 chat application. It builds on `docs/architecture/stimulus-guidelines.md` and targets intermediate developers. Components are UI primitives in `app/javascript/controllers/components/`, integrated with views for consistent behavior.

## Table of Contents
- [Stimulus Component Guidelines](#stimulus-component-guidelines)
  - [Table of Contents](#table-of-contents)
  - [1. Overview](#1-overview)
  - [2. Naming and Organization](#2-naming-and-organization)
  - [3. Controller Structure](#3-controller-structure)
    - [Controller Naming](#controller-naming)
  - [4. DOM Attributes](#4-dom-attributes)
    - [Controller Binding](#controller-binding)
    - [Targets](#targets)
    - [Actions](#actions)
    - [Multiple Actions](#multiple-actions)
    - [Values](#values)
  - [5. Component Communication](#5-component-communication)
    - [Event Dispatch](#event-dispatch)
    - [Event Listening](#event-listening)
  - [6. Common Components](#6-common-components)
    - [Drawer Component](#drawer-component)
    - [Dropdown Component](#dropdown-component)
  - [7. Testing Components](#7-testing-components)
  - [8. Related Resources](#8-related-resources)

## 1. Overview

Stimulus components are reusable UI elements (e.g., drawers, alerts) that encapsulate JavaScript behavior, styled with TailwindCSS and integrated with Rails views. They extend `BaseController` for debugging and use event dispatching for coordination. This guide covers their structure, DOM integration, accessibility, and usage in views like `shared/_flash.html.erb`.

See `app/javascript/controllers/components/drawer_controller.js` for an example.


## 2. Naming and Organization

Components live in `app/javascript/controllers/components/`:
```
app/javascript/controllers/
  ├── application.js    # Main application controller
  ├── index.js          # Controller registry
  ├── components/       # Generic reusable UI components
  │   ├── drawer_controller.js
  │   ├── alert_controller.js
  │   ├── dropdown_controller.js
  │   └── ...
  ├── chats/           # Domain-specific controllers
  │   ├── chat_list_controller.js
  │   └── chat_edit_controller.js
  ├── debug/           # Development & debugging tools
  │   └── ...
  └── helpers/         # Shared helpers
      └── ...
```


## 3. Controller Structure

> [!IMPORTANT]
> This controller structure applies to ALL controllers in the application, not just component controllers. The same pattern should be followed for domain-specific controllers in `chats/`, app-wide controllers in `app/`, and debugging controllers in `debug/`. See [Stimulus Guidelines - Standard Controller Structure](/docs/architecture/stimulus-guidelines.md#31-standard-controller-structure) for more details.

Component controllers follow the structure defined in [Stimulus Guidelines](/docs/architecture/stimulus-guidelines.md), with the following template tailored for components:

### Controller Naming

Follows the pattern `data-controller="namespace--name"`:  
- For domain-specific logic: `data-controller="chats--chat-list"`
- For reusable components: `data-controller="components--drawer"`

> [!NOTE]
> Add a comment to the top of the controller file to indicate the controller name e.g.:
> ```js
> // Connects to data-controller="components--drawer"
> ``` 


```js
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
    // Initialization logic
  }

  disconnect() {
    // Cleanup logic
  }

  // 3. Target Lifecycle Methods (ordered alphabetically)
  // ----------------------
  elementTargetConnected() {
    // Do something
  }

  elementTargetDisconnected() {
    // Do something
  }

  // 4a. Public Action Methods (ordered alphabetically)
  // ----------------------
  close() {
    // Public method implementation
  }

  open() {
    // Public method implementation
  }

  // 4b. Public Dispatch Action Methods (ordered alphabetically)
  // ----------------------
  action(event, detail) {
    // Do something
  }

  // 5. Private Helper Methods (ordered alphabetically)
  // ----------------------
  #handleCancel(event) {
    // Private method implementation
  }
  
  // 6. Getters / Setters / Computed Properties (ordered alphabetically)
  // ----------------------
  get isOpen() {
    return this.openValue;
  }
}
```

**Key Elements**:
- **Static Definitions**: Define `targets` and `values`.
- **Lifecycle Methods**: Use `connect`/`disconnect` for setup/cleanup.
- **Actions**: Public methods like `close` for user interactions.
- **Private Helpers**: Prefixed with `#` for internal logic.


## 4. DOM Attributes

Components use Stimulus attributes in views for binding, targets, actions, and values.

### Controller Binding
```erb
<div data-controller="components--drawer">
  <!-- Controller content -->
</div>
```

### Targets

Use targets to reference DOM elements:

```erb
<button data-components--drawer-target="drawerButton">
  Open Drawer
</button>

<dialog data-components--drawer-target="dialog">
  <!-- Dialog content -->
</dialog>
```

### Actions
```erb
<button 
  data-action="components--drawer#open"
  aria-label="Open drawer">
  Open
</button>
```

### Multiple Actions

For multiple actions, use a space-separated list:

```erb
<!-- app/views/chats/_form_edit.html.erb -->
<form data-action="
  keydown.esc->chats--chat-edit#cancelEdit:prevent 
  keydown.shift->chats--chat-edit#detectShiftTab
  keydown.tab->chats--chat-edit#detectTab
">
  <!-- Form content -->
</form>
```

### Values

Values allow data to be passed to the controller:

```erb
<!-- app/views/shared/_drawer.html.erb -->
<div 
  data-controller="components--drawer"
  data-components--drawer-open-value="true">
  <!-- Content -->
</div>
```


## 5. Component Communication

Use `dispatch` for event-based communication, as detailed in [Stimulus Dispatch Guidelines](/docs/architecture/stimulus-dispatch-guidelines.md).

### Event Dispatch
```js
// In drawer_controller.js
this.dispatch("open", { detail: { open: true } });
```

### Event Listening

Listen for dispatched events using @window (for global events) or from child components using direct binding.

```erb
<div 
  data-controller="parent-controller"
  data-action="components--drawer:open@window->chats--chat-list#openDrawer">
  <!-- Content -->
</div>
```


## 6. Common Components

### Drawer Component
```erb
<%= render partial: "shared/drawer" %>
```

Key features:
- Built with native `<dialog>`
- Uses `components--drawer` controller
- Handles keyboard events
- Manages focus and accessibility


### Dropdown Component
```erb
<div data-controller="components--dropdown">
  <button data-components--dropdown-target="menuButton" data-action="components--dropdown#toggle">
    Toggle
  </button>
  <div data-components--dropdown-target="menu" class="hidden">
    <!-- Menu items -->
  </div>
</div>
```

**Features**:
- Click-outside detection.
- ARIA support (`aria-expanded`).
- Keyboard navigation (`up`/`down`).


## 7. Testing Components

Test components using Stimulus testing helpers, focusing on:
- JavaScript behavior (e.g., `close` action in `alert_controller.js`).
- DOM interactions (e.g., `aria-expanded` in `dropdown_controller.js`).
- Accessibility (e.g., keyboard navigation, ARIA roles).

See [Stimulus Testing Guidelines](/docs/testing/stimulus-testing-guidelines.md) for details.


## 8. Related Resources
- **Code**:
  - [Drawer Controller](/app/javascript/controllers/components/drawer_controller.js)
  - [Dropdown Controller](/app/javascript/controllers/components/dropdown_controller.js)
  - [Alert Controller](/app/javascript/controllers/components/alert_controller.js)
  - [Base Controller](/app/javascript/controllers/base_controller.js)
  - [Drawer Partial](/app/views/shared/_drawer.html.erb)
  - [Flash Partial](/app/views/shared/_flash.html.erb)
- **Guidelines**:
  - [Stimulus Guidelines](/docs/architecture/stimulus-guidelines.md)
  - [Stimulus Dispatch Guidelines](/docs/architecture/stimulus-dispatch-guidelines.md)
  - [Technical Overview](/docs/architecture/technical-overview.md)
  - [Stimulus Component Testing](/docs/testing/stimulus-testing-guidelines.md)
  - [Architecture Overview](/docs/architecture/README.md)
- **External**:
  - [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
  - [Stimulus Component Examples](https://github.com/excid3/tailwindcss-stimulus-components)
  - [Dialog Element Documentation](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dialog)

---

Let's **Stimulate** Beautifully! 🩵
