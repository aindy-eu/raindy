---
title: "Controller Testing Guidelines"
description: "Standards for writing controller tests to verify HTTP-level interactions in a Rails 8 chat application using ActionDispatch::IntegrationTest"
updated: "2025-05-15 10:23:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: xai-grok-3
    ai: true
pillar: "Testing"
tags: ["testing", "controller-tests", "actiondispatch", "turbo-stream", "guideline"]
related_docs:
  - path: "/app/controllers/chats_controller.rb"
  - path: "/app/views/chats/create.turbo_stream.erb"
  - path: "/docs/testing/integration-testing-guidelines.md"
  - path: "/docs/testing/system-testing-guidelines.md"
  - path: "/docs/testing/model-testing-guidelines.md"
---

# Controller Testing Guidelines

This guide defines standards for writing **controller tests** to verify HTTP-level interactions (requests, responses, redirects) in this Rails application, focusing on single controller actions for chats, authentication, and dashboard rendering. Controller tests use `ActionDispatch::IntegrationTest` to test routing, Turbo Stream responses, and access control, ensuring fast feedback. For multi-step flows, see [Integration Testing Guidelines](/docs/testing/integration-testing-guidelines.md). For UI interactions, see [System Testing Guidelines](/docs/testing/system-testing-guidelines.md).


## Table of Contents
- [Controller Testing Guidelines](#controller-testing-guidelines)
  - [Table of Contents](#table-of-contents)
  - [1. Overview](#1-overview)
  - [2. Quick Start](#2-quick-start)
  - [3. Folder Structure](#3-folder-structure)
  - [4. When to Use Controller Tests](#4-when-to-use-controller-tests)
  - [5. Common Patterns](#5-common-patterns)
    - [Setup](#setup)
    - [CRUD Actions](#crud-actions)
    - [Turbo Stream Responses](#turbo-stream-responses)
    - [Access Protection](#access-protection)
    - [Edge Cases](#edge-cases)
    - [Sessions and Authentication](#sessions-and-authentication)
    - [Dashboard Rendering](#dashboard-rendering)
  - [6. Conventions](#6-conventions)
    - [Naming Conventions](#naming-conventions)
  - [7. Related Resources](#7-related-resources)

## 1. Overview

Controller tests verify single controller actions (e.g., `ChatsController#create`, `SessionsController#destroy`), focusing on:
- HTTP responses (status, redirects).
- Turbo Stream updates (e.g., prepending chats to `chats--chat-list`).
- Accessible flash messages using `I18n.t` (e.g., `shared/_flash.html.erb` with `components--alert`).
- Access control via `authenticate_user!` (e.g., `authentication.rb`).

They are faster than system tests and complement model tests ([Model Testing Guidelines](/docs/testing/model-testing-guidelines.md)) for validations and integration tests for multi-step flows.

**Flowchart**:

```plaintext
Test Scenario
├── Single Action? (e.g., ChatsController#create) → Controller Test
├── Multi-Step Flow? (e.g., login → dashboard) → Integration Test
├── UI Interaction? (e.g., drawer navigation) → System Test
└── Model Logic? (e.g., chat validations) → Model Test
```

## 2. Quick Start

1. **Create a Test File**: Name it `[action]_test.rb` (e.g., `create_test.rb`).
   ```ruby
   # test/controllers/chats/create_test.rb
   class ChatsCreateTest < ActionDispatch::IntegrationTest
   ```
2. **Set Up**: Use FactoryBot and `login_as` from test helpers.
   ```ruby
   setup do
     @user = create(:user)
     login_as(@user)
   end
   ```
3. **Write a Test**: Use `[user or role] [performs action]...` format.
   ```ruby
   test "user creates a chat via HTML and sees success" do
     post chats_url, params: { chat: { name: "New Chat" } }
     assert_redirected_to chats_url(locale: I18n.locale)
     assert_equal I18n.t("helpers.created", model: Chat.model_name.human), flash[:notice]
   end
   ```
4. **Test Turbo Stream**:
   ```ruby
   test "user creates a chat via Turbo Stream" do
     post chats_url(format: :turbo_stream), params: { chat: { name: "Turbo Chat" } }
     assert_turbo_stream action: "prepend", target: "chats"
   end
   ```

**Note**: Turbo Streams trigger Stimulus actions (e.g., `chats--chat-list`); UI testing is covered in `docs/testing/system-testing-guidelines.md`.

## 3. Folder Structure

```plaintext
test/controllers/
├── chats/
│   ├── create_test.rb
│   ├── destroy_test.rb
│   ├── update_test.rb
├── sessions/
│   ├── create_test.rb
│   ├── destroy_test.rb
├── chats_controller_test.rb      # Legacy or shared chat tests
├── sessions_controller_test.rb   # Session tests (authentication)
├── dashboard_controller_test.rb  # Dashboard rendering tests
```

- Use subfolders (e.g., `chats/`) for action-specific tests (e.g., `create_test.rb`).
- Use `[controller]_controller_test.rb` for shared, legacy, or simple controllers (e.g., `sessions_controller_test.rb`).
- Place dashboard tests in `dashboard_controller_test.rb` for chat list rendering.

## 4. When to Use Controller Tests

| Use If...                                                 | Don't Use If...                                    |
| --------------------------------------------------------- | -------------------------------------------------- |
| Testing a single action (e.g., `ChatsController#create`)  | Testing UI interactions (e.g., drawer navigation)  |
| Verifying HTTP responses (e.g., redirects to `chats_url`) | Testing multi-step flows (e.g., login → dashboard) |
| Testing Turbo Stream updates (e.g., chat list prepend)    | Testing Stimulus behavior (e.g., alert dismissal)  |
| Testing accessible flash messages (e.g., `I18n.t`)        | Testing model validations                          |

See [Model Testing Guidelines](/docs/testing/model-testing-guidelines.md) for validations and [System Testing Guidelines](/docs/testing/system-testing-guidelines.md) for UI.

## 5. Common Patterns

### Setup
Use FactoryBot and `login_as` for consistent test setup.
```ruby
class ChatsCreateTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    login_as(@user)
  end
end
```

See [Test Helpers Guidelines (Light)](/docs/testing/test-helpers-guidelines-light.md) for `login_as`.

### CRUD Actions
Test HTTP requests, redirects, and flash messages for chat actions.
```ruby
test "user creates a chat via HTML and sees success" do
  post chats_url, params: { chat: { name: "New Chat" } }
  assert_redirected_to chats_url(locale: I18n.locale)
  assert_equal I18n.t("helpers.created", model: Chat.model_name.human), flash[:notice]
  assert Chat.exists?(name: "New Chat")
end
```

**Note**: Chats use `name` presence validation (`app/models/chat.rb`); test edge cases separately.

### Turbo Stream Responses
Verify Turbo Stream actions for real-time updates, linked to `create.turbo_stream.erb` or `destroy.turbo_stream.erb`.
```ruby
test "user deletes a chat via Turbo Stream" do
  chat = create(:chat, user: @user)
  delete chat_url(chat, format: :turbo_stream)
  assert_turbo_stream action: "remove", target: dom_id(chat)
  assert_equal I18n.t("helpers.deleted", model: Chat.model_name.human), flash[:notice]
end
```

**Note**: Turbo Streams interact with `chats--chat-list` or `components--alert`; test UI in system tests.

### Access Protection
Ensure `authenticate_user!` redirects guests to login.
```ruby
test "guest cannot access chats" do
  get chats_url
  assert_redirected_to new_session_url(locale: I18n.locale)
  assert_equal I18n.t("authentication.alerts.not_authenticated"), flash[:alert]
end
```

### Edge Cases
Test invalid inputs or error states.
```ruby
test "user fails to create chat with blank name" do
  post chats_url, params: { chat: { name: "" } }
  assert_response :unprocessable_entity
  assert_match I18n.t("activerecord.errors.models.chat.attributes.name.blank"), response.body
end
```

### Sessions and Authentication
Test authentication flows (e.g., sign-in, sign-out) with redirects.
```ruby
test "user signs out and sees login page" do
  login_as(@user)
  delete session_url
  assert_redirected_to new_session_url(locale: I18n.locale)
  assert_equal I18n.t("authentication.alerts.signed_out"), flash[:alert]
end
```

**Note**: Sessions tests focus on redirects (`new_session_url`) and flash messages, with minimal rendering.

### Dashboard Rendering
Test chat list rendering on the dashboard.
```ruby
test "user views dashboard and sees chat list" do
  chat = create(:chat, user: @user)
  get chats_url
  assert_response :success
  assert_match chat.name, response.body
end
```

**Note**: Dashboard renders `_chat.html.erb` with `chats--chat-list`; test Stimulus UI (e.g., drawer) in system tests.

## 6. Conventions

| Practice                        | Example                                                       |
|---------------------------------|---------------------------------------------------------------|
| Use FactoryBot                  | `create(:user)`                                               |
| Use `I18n.t` for flash messages | `assert_equal I18n.t("helpers.created", ...), flash[:notice]` |
| Use path helpers                | `chats_url(locale: I18n.locale)`                              |
| Use `assert_turbo_stream`       | `assert_turbo_stream action: "prepend", target: "chats"`      |
| Define `login_as`               | `login_as(@user)`                                             |
| Test redirects for sessions     | `assert_redirected_to new_session_url`                        |
| Test rendering for dashboard    | `assert_match chat.name, response.body`                       |

### Naming Conventions
- **Files**: Use `[action]_test.rb` (e.g., `create_test.rb`) for action-specific tests or `[controller]_controller_test.rb` (e.g., `sessions_controller_test.rb`) for shared tests.
- **Methods**: `[user or role] [performs action] [via format or context] [and sees outcome]` (e.g., `"user creates a chat via HTML and sees success"`).

## 7. Related Resources

- **Code**:
  - [Chats Controller](/app/controllers/chats_controller.rb)
  - [Turbo Stream View](/app/views/chats/create.turbo_stream.erb)
  - [Flash View](/app/views/shared/_flash.html.erb)
- **Guidelines**:
  - [Integration Testing](/docs/testing/integration-testing-guidelines.md)
  - [System Testing](/docs/testing/system-testing-guidelines.md)
  - [Model Testing](/docs/testing/model-testing-guidelines.md)
  - [Testing Overview](/docs/testing/README.md)
- **External**:
  - [Rails Guides — Controller Testing](https://guides.rubyonrails.org/testing.html#functional-tests-for-your-controllers)
  - [Turbo Stream Test Helpers](https://github.com/hotwired/turbo-rails/blob/main/test/assertions.rb)

---

Let's **Control** Tests Beautifully! ❤️
