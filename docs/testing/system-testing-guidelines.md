---
title: "System Testing Guidelines"
description: "Standard for writing system tests to verify user interactions using Capybara and Minitest"
updated: "2025-05-15 10:27:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: grok-xai
    ai: true
pillar: "Testing"
tags: ["testing", "system-tests", "minitest", "capybara", "guideline"]
related_docs:
  - path: "/app/views/chats/_chat.html.erb"
  - path: "/app/views/chats/create.turbo_stream.erb"
  - path: "/docs/testing/controller-testing-guidelines.md"
  - path: "/docs/testing/integration-testing-guidelines.md"
  - path: "/docs/testing/model-testing-guidelines.md"
---

# System Testing Guidelines

This document defines a universal standard for writing **system tests** that simulate user interactions in a browser-like environment using Capybara and Minitest. System tests ensure that user flows, UI updates, keyboard navigation, and accessibility for chats and authentication flows. They complement controller tests (`docs/testing/controller-testing-guidelines.md`) for HTTP actions, integration tests (`docs/testing/integration-testing-guidelines.md`) for multi-step flows, and model tests (`docs/testing/model-testing-guidelines.md`) for validations.

The term `resource` refers to the model being tested (e.g., `chat`).

## Table of Contents
- [System Testing Guidelines](#system-testing-guidelines)
  - [Table of Contents](#table-of-contents)
  - [1. Overview](#1-overview)
  - [2. Folder Structure](#2-folder-structure)
  - [3. When to Use System Tests](#3-when-to-use-system-tests)
  - [4. Structure and Style](#4-structure-and-style)
  - [5. Common Patterns](#5-common-patterns)
    - [Setup](#setup)
    - [Sign-In Strategies](#sign-in-strategies)
    - [CRUD Actions](#crud-actions)
    - [Keyboard Navigation](#keyboard-navigation)
    - [Turbo Stream Updates](#turbo-stream-updates)
    - [Accessibility](#accessibility)
    - [Validation Testing](#validation-testing)
  - [6. Conventions](#6-conventions)
    - [Naming Conventions](#naming-conventions)
      - [Test File Names](#test-file-names)
      - [Test Method Names](#test-method-names)
  - [7. Related Resources](#7-related-resources)

## 1. Overview

System tests are end-to-end tests that simulate user interactions in a browser, verifying:
- UI interactions (e.g., clicking to create chats in `_chat.html.erb`).
- Turbo Stream updates (e.g., `create.turbo_stream.erb`).
- Keyboard navigation (e.g., Tab, Enter for `chats--chat-edit`).
- Accessibility (e.g., ARIA attributes, WCAG 2.1 compliance).

They are slower than controller/integration tests but ensure a realistic user experience.

**System tests are NOT**:
- For HTTP responses without UI (use controller tests).
- For model logic (use model tests).
- For non-browser flows (use integration tests).

>Note: Unlike controller/integration tests, system tests often require multiple setup steps (Capybara config, UI helpers, etc.), so this guide focuses on copyable examples and conventions rather than a single quick start.

## 2. Folder Structure

```plaintext
- test/system/
  - <domain>/
      - <action>_test.rb (e.g., create_test.rb, edit_test.rb)
      - <action>_with_<context>_test.rb (e.g., edit_with_keyboard_test.rb)
  - auth/
      - sign_in_sign_out_test.rb
      - sign_in_sign_out_mobile_test.rb
  - dashboard/
      - drawer/
          - resource_<action>_test.rb (e.g., chat_create_with_click_test.rb)
          - resource_list_<state>_test.rb (e.g., chat_list_empty_state_test.rb)
          - resource_<action>_with_<context>_test.rb (e.g., chat_edit_with_shift_tab_test.rb)
  - stimulus/
      - components/
          - drawer_test.rb
          - dropdown/
              - main_navigation_dropdown_test.rb
```

- **Group by domain**: `chats/`, `auth/`, `dashboard/drawer/`, etc.
- **Separate CRUD and contextual tests**: `create_test.rb` for general CRUD, `create_with_keyboard_test.rb` for keyboard-specific flows.
- **Drawer tests**: Use `<model>_` (e.g., `chat_`) or `<model>_list_` prefix in `dashboard/drawer/` to reflect the feature (e.g., `chat_create_with_click_test.rb`).
- **Mobile tests**: Use `MobileSystemTestCase` for mobile-specific tests (e.g., `sign_in_sign_out_mobile_test.rb`).

## 3. When to Use System Tests

| Use System Tests If...                  | Don't Use If...                    |
| --------------------------------------- | ---------------------------------- |
| Testing UI interactions (clicks, forms) | Testing HTTP responses without UI  |
| Verifying Turbo Stream updates          | Testing model logic                |
| Testing keyboard navigation and focus   | Testing non-browser flows          |
| Ensuring accessibility (ARIA, focus)    | Needing fast, lightweight feedback |

## 4. Structure and Style

- **Base Class**: `ApplicationSystemTestCase` (configured with Capybara).
- **Setup**:
  - Use FactoryBot (`create(:user)`, `create(:resource)`).
  - Sign-in strategy depends on the test context (see [Sign-In Strategies](#sign-in-strategies)).
- **Test File Names**:
  - Follow the naming convention: `[Feature]_[Behavior]_[Context/Qualifier]_test.rb`, substituting `Resource` with your model (e.g., `Chat`) (see [Naming Conventions](#naming-conventions)).
  - Examples: `resource_create_with_click_test.rb`, `resource_list_empty_state_test.rb`.
- **Test Method Names**:
  - Descriptive and user-focused: `"user creates a new resource in the drawer"`.
  - Include context for keyboard tests: `"user edits resource with Enter key"`.
  - Follow the pattern: `[user or role] [performs sequence of interactions] [and sees outcome or feedback]`.
- **Assertions**:
  - Use `assert_text` with `I18n.t` for localized content.
  - Scope with `within("turbo-frame#chats_new")` for precision.
  - Use `wait: 5` for Turbo Stream updates.
  - Verify focus with `assert_selector "...:focus"`.

## 5. Common Patterns

### Setup

```ruby
class ChatsCreateTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
    @chat = create(:chat, user: @user)
    sign_in(@user)
    @drawer = TestHelpers::System::DrawerHelper.new
  end
end
```

### Sign-In Strategies

**Dashboard Test**:
  ```ruby
  setup do
    @user = create(:user)
    sign_in(@user)
  end

  test "user views chat list" do
    visit chats_path
    assert_text I18n.t("helpers.navigation.chats")
  end
  ```


### CRUD Actions

**Create a Chat**:
```ruby
test "user creates a chat and sees it listed" do
  sign_in(@user)
  visit chats_path
  within("turbo-frame#chats_new") do
    fill_in "chat[name]", with: "New Chat"
    click_button I18n.t("helpers.submit.create", model: Chat.model_name.human)
  end
  within("div#chats") do
    assert_text "New Chat", wait: 5
  end
  assert Chat.exists?(name: "New Chat")
end
```

**Edit a Chat**:
```ruby
test "user edits a chat and sees update" do
  sign_in(@user)
  visit chats_path
  within("turbo-frame##{dom_id(@chat)}") do
    click_link I18n.t("helpers.button.rename")
    fill_in "chat[name]", with: "Updated Chat"
    find("[data-chats--chat-edit-target='chatNameInput']").send_keys(:enter)
    assert_text "Updated Chat", wait: 5
  end
  assert_equal "Updated Chat", @chat.reload.name
end
```

### Keyboard Navigation

**Tab Navigation**:
```ruby
test "user navigates to edit link with Tab" do
  sign_in(@user)
  visit chats_path
  find("body").send_keys(:tab) until page.has_selector?("[data-chats--chat-list-target='editChatLink']:focus")
  assert_selector "turbo-frame##{dom_id(@chat)} [data-chats--chat-list-target='editChatLink']:focus", wait: 5
end
```

**Escape Cancellation**:
```ruby
test "user cancels edit with Escape" do
  sign_in(@user)
  visit chats_path
  within("turbo-frame##{dom_id(@chat)}") do
    click_link I18n.t("helpers.button.rename")
    find("input[name='chat[name]']").send_keys(:escape)
    assert_text @chat.name
  end
end
```

### Turbo Stream Updates

- Use `wait` for DOM updates after Turbo Stream responses:

```ruby
test "user deletes a chat and sees it removed" do
  sign_in(@user)
  visit chats_path
  within("turbo-frame##{dom_id(@chat)}") do
    accept_confirm(I18n.t("helpers.confirm")) do
      click_link I18n.t("helpers.button.delete")
    end
  end
  assert_no_selector "turbo-frame##{dom_id(@chat)}", wait: 5
end
```

### Accessibility

```ruby
test "chat form has ARIA attributes" do
  sign_in(@user)
  visit chats_path
  within("turbo-frame##{dom_id(@chat)}") do
    click_link I18n.t("helpers.button.rename")
    assert_selector "form[role='form'][aria-label='#{I18n.t("chats.chat.form_edit_aria")}']", visible: true
  end
end
```

### Validation Testing

```ruby
test "user sees error for blank chat name" do
  sign_in(@user)
  visit chats_path
  within("turbo-frame#chats_new") do
    fill_in "chat[name]", with: ""
    click_button I18n.t("helpers.submit.create", model: Chat.model_name.human)
  end
  assert_selector "div[aria-live='polite']", text: I18n.t("activerecord.errors.models.chat.attributes.name.blank"), wait: 5
end
```

## 6. Conventions

| Practice                      | Example                                          |
|-------------------------------|--------------------------------------------------|
| Use FactoryBot                | `create(:user)`                                  |
| Localized assertions          | `assert_text I18n.t("helpers.button.rename")`    |
| Scope with `within`           | `within("turbo-frame#chats_new")`                |
| Use `turbo-frame` IDs         | `within("turbo-frame#chats_new")`                |
| Use `wait` for Turbo Streams  | `assert_text "New Chat", wait: 5`                |
| Verify focus                  | `assert_selector "...:focus", wait: 5`           |

### Naming Conventions

System test files and test methods follow structured naming conventions to ensure clarity, consistency, and scalability. Substitute `Resource` with your model name (e.g., `Chat`) in file names.

#### Test File Names

- **Pattern**: `[Feature]_[Behavior]_[Context/Qualifier]_test.rb`
  - **Feature**: The primary UI component or functionality, typically the model name (e.g., `Resource`, `Chat`) or its list (e.g., `ResourceList`, `ChatList`). In the `dashboard/drawer/` folder, use `Resource` for actions (e.g., creation, editing) or `ResourceList` for list states or interactions.
  - **Behavior**: The specific action, state, or outcome being tested (e.g., `Create`, `Edit`, `EmptyState`, `ActiveResource`).
  - **Context/Qualifier** (optional): Additional context, such as the input method (`WithKeyboard`, `WithClick`), UI state (`Blur`, `Enter`), or scope (`UI`). Use only when needed to disambiguate or clarify.
  - **\_test.rb**: Standard Minitest suffix.
- **Guidelines**:
  - **Omit Redundant Context/Qualifiers**: When a folder name already provides context (such as `dashboard/drawer/`), do not repeat that context or feature name (like "drawer" or "feature") in the file names.
    - Use `resource_ui_test.rb` instead of `drawer_resource_ui_test.rb` or `feature_resource_ui_test.rb` inside the `dashboard/drawer/` folder.
    - The folder structure should make the context clear, so file names can be concise and focused on the specific resource or behavior being tested.
  - **Start with Feature**: Begin with the feature (e.g., `Resource`, `ResourceList`) to group related tests visually in the directory (e.g., `resource_list_*` files appear together when sorted).
  - **Be Specific with Behavior**: Use precise terms for the behavior or state (e.g., `EmptyState`, `ActiveResource`, `Create`, `Edit`).
  - **Use Context Sparingly**: Add qualifiers like `WithKeyboard`, `WithClick`, or `UI` only when they clarify the test’s scope or distinguish it from similar tests (e.g., `resource_edit_with_keyboard_test.rb` vs. `resource_edit_with_click_test.rb`).
  - **Keep Names Concise**: Aim for clarity without excessive length. Avoid vague terms like “Behavior” or “Display”.
  - **CamelCase for Classes**: Use CamelCase for test class names, matching the file name (e.g., `resource_list_empty_state_test.rb` → `ResourceListEmptyStateTest`).
  - **Model Substitution**: Replace `Resource` with your model name (e.g., `Chat` → `chat_create_with_click_test.rb`).
- **Examples** (Generic):
  - `resource_create_with_click_test.rb`: Tests creating a resource via clicking.
  - `resource_list_empty_state_test.rb`: Tests the resource list’s empty state.
  - `resource_edit_with_shift_tab_test.rb`: Tests editing a resource with Shift+Tab.
  - `resource_ui_test.rb`: Tests the overall resource-related UI in the drawer (title, form, list).
  - `resource_list_edit_link_focus_with_keyboard_test.rb`: Tests focusing the edit link in the resource list using the keyboard.
- **Common Context/Qualifier Terms**:
  - `WithKeyboard`
  - `WithClick`
  - `WithEnter`
  - `WithTab`
  - `WithShiftTab`
  - `Blur`
  - `UI`

#### Test Method Names

- **Pattern**: `[user or role] [performs sequence of interactions] [and sees outcome or feedback]`
  - Describe the user’s actions and the expected UI or database outcome.
  - Be action-oriented and specific about the interaction method (e.g., clicking, pressing a key).
- **Guidelines**:
  - Use present tense for actions (e.g., “creates”, “edits”, “sees”).
  - Include the interaction method for contextual tests (e.g., “with Enter key”, “with Tab key”).
- **Examples**:
  - `"user creates a new chat and sees it listed"`
  - `"user edits a chat with Enter key and sees it updated"`
  - `"user navigates to edit link with Tab key and restores focus after drawer reopen"`


## 7. Related Resources

- **Code**:
  - [Chat List View](/app/views/chats/_chat.html.erb)
  - [Turbo Stream View](/app/views/chats/create.turbo_stream.erb)
  - [Flash View](/app/views/shared/_flash.html.erb)
- **Guidelines**:
  - [Controller Testing](/docs/testing/controller-testing-guidelines.md)
  - [Integration Testing](/docs/testing/integration-testing-guidelines.md)
  - [Model Testing](/docs/testing/model-testing-guidelines.md)
  - [Testing Overview](/docs/testing/README.md)
  - [Architecture Overview](/docs/architecture/README.md)
  - [Testing Glossary](/docs/testing/testing-glossary.md)
- **External**:
  - [Rails Guides — System Testing](https://guides.rubyonrails.org/testing.html#system-testing)
  - [Capybara Documentation](https://github.com/teamcapybara/capybara)
  - [Minitest Documentation](https://github.com/minitest/minitest)

---

Let’s **Simulate** Tests Beautifully! ❤️
