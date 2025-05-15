---
title: "Integration Testing Guidelines"
description: "Concise guidelines for writing integration tests for multi-step, cross-controller flows in a Rails 8 chat application"
updated: "2025-05-15 10:24:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: xai-grok-3
    ai: true
pillar: "Testing"
tags: ["testing", "integration", "controllers", "turbo-stream", "guideline"]
related_docs:
  - path: "/app/controllers/chats_controller.rb"
  - path: "/app/views/chats/create.turbo_stream.erb"
  - path: "/docs/testing/controller-testing-guidelines.md"
  - path: "/docs/testing/system-testing-guidelines.md"
  - path: "/docs/testing/model-testing-guidelines.md"
---

# Integration Testing Guidelines

This guide provides standards for writing **integration tests** to verify multi-step, cross-controller flows in this Rails 8 chat application, covering authentication, chat management, and dashboard rendering. Integration tests use `ActionDispatch::IntegrationTest` to test requests, redirects, flash messages, session state, and Turbo Stream responses across controllers, without browser simulation. For single actions, see [Controller Testing Guidelines](/docs/testing/controller-testing-guidelines.md). For UI interactions, see [System Testing Guidelines](/docs/testing/system-testing-guidelines.md).

The term `resource` refers to the model being tested (e.g., `chat`).

## Table of Contents
- [Integration Testing Guidelines](#integration-testing-guidelines)
  - [Table of Contents](#table-of-contents)
  - [1. Overview](#1-overview)
  - [2. Quick Start](#2-quick-start)
  - [3. Folder Structure](#3-folder-structure)
  - [4. Common Patterns](#4-common-patterns)
    - [Setup](#setup)
    - [Multi-Step Flow](#multi-step-flow)
    - [Turbo Stream Flow](#turbo-stream-flow)
    - [Flash Messages](#flash-messages)
    - [Access Protection](#access-protection)
  - [Conventions](#conventions)
    - [Naming Conventions](#naming-conventions)
  - [6. Flow Examples](#6-flow-examples)
    - [Authentication Flow](#authentication-flow)
    - [Chat Creation Flow](#chat-creation-flow)
    - [Dashboard Rendering Flow](#dashboard-rendering-flow)
  - [7. Related Resources](#7-related-resources)

## 1. Overview

Integration tests verify multi-step flows across controllers (e.g., login → redirect → dashboard), focusing on:
- Session state (`session[:user_id]` via `authentication.rb`).
- Turbo Stream updates (e.g., `create.turbo_stream.erb`).
- Accessible flash messages using `I18n.t` (`shared/_flash.html.erb`).
- Cross-controller redirects and rendering.

They are faster than system tests and complement controller tests (`docs/testing/controller-testing-guidelines.md`) for single actions and model tests (`docs/testing/model-testing-guidelines.md`) for validations.

**Example**: Testing login (`SessionsController`) → redirect → dashboard (`ChatsController#index`).

## 2. Quick Start
1. **Create a Test File**: Name it `[feature]_[behavior]_flow_test.rb` (e.g., `chat_create_flow_test.rb`).
   ```ruby
   # test/integration/chats/create_flow_test.rb
   class ChatsCreateFlowTest < ActionDispatch::IntegrationTest
   ```
2. **Set Up**: Use FactoryBot and `login_as` from test helpers.
   ```ruby
   setup do
     @user = create(:user)
     login_as(@user)
   end
   ```
3. **Write a Flow**: Test multi-step actions (e.g., create → redirect → render). Verify redirects, flash messages, and content.
   ```ruby
   test "user creates a chat via HTML and sees it listed" do
     post chats_url, params: { chat: { name: "New Chat" } }
     follow_redirect!
     assert_response :success
     assert_equal I18n.t("helpers.created", model: Chat.model_name.human), flash[:notice]
     assert_match "New Chat", response.body
   end
   ```

4. **Test Turbo Streams**: Use `assert_turbo_stream` to verify Turbo Stream updates.
   ```ruby
   test "user creates a chat via Turbo Stream" do
     post chats_url(format: :turbo_stream), params: { chat: { name: "Turbo Chat" } }
     assert_turbo_stream action: "prepend", target: "chats"
   end
   ```

**Note**: Turbo Streams update the UI without full page reloads, common in the chat list.

## 3. Folder Structure

```plaintext
- test/integration/
  - chats/
    - create_flow_test.rb
    - update_flow_test.rb
    - destroy_flow_test.rb
  - auth/
    - authentication_flow_test.rb
```
- Group tests by domain: `chats/` for chat flows, `auth/` for authentication.
- Use `_flow_test.rb` suffix (e.g., `create_flow_test.rb`).

## 4. Common Patterns

### Setup

```ruby
class ChatsCreateFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    login_as(@user)
  end
end
```

### Multi-Step Flow
Test create → redirect → render:
```ruby
test "user creates a chat via HTML and sees it listed" do
  post chats_url, params: { chat: { name: "New Chat" } }
  assert_redirected_to chats_url(locale: I18n.locale)
  follow_redirect!
  assert_response :success
  assert_equal I18n.t("helpers.created", model: Chat.model_name.human), flash[:notice]
  assert_match "New Chat", response.body
end
```

### Turbo Stream Flow
Test Turbo Stream updates:
```ruby
test "user creates a chat via Turbo Stream" do
  post chats_url(format: :turbo_stream), params: { chat: { name: "Turbo Chat" } }
  assert_turbo_stream action: "prepend", target: "chats"
  assert Chat.exists?(name: "Turbo Chat")
end
```

### Flash Messages
Test success/error messages:
```ruby
test "user fails to create a chat with invalid data" do
  post chats_url, params: { chat: { name: "" } }
  assert_response :unprocessable_entity
  assert_select ".error", text: I18n.t("errors.messages.blank")
end
```

For flash messages in Turbo Stream responses, use the `assert_turbo_flash` helper:
```ruby
test "user updates chat via Turbo Stream and sees success message" do
  patch chat_url(@chat, format: :turbo_stream), params: { chat: { name: "Updated Name" } }
  assert_turbo_flash("dialog_flash_messages")
end
```

This helper verifies that a flash message is properly rendered in the specified target container.

### Access Protection
Test unauthorized access:
```ruby
test "guest cannot access chats" do
  get chats_url
  assert_redirected_to new_session_url(locale: I18n.locale)
  assert_equal I18n.t("authentication.alerts.not_authenticated"), flash[:alert]
end
```

**Note**: Use `I18n.t` for flash messages to ensure localization and screen-reader compatibility.

## Conventions
| Practice                        | Example                                                       |
| ------------------------------- | ------------------------------------------------------------- |
| Use FactoryBot                  | `create(:user)`                                               |
| Use `I18n.t` for flash messages | `assert_equal I18n.t("helpers.created", ...), flash[:notice]` |
| Use path helpers                | `chats_url(locale: I18n.locale)`                              |
| Use `assert_turbo_stream`       | `assert_turbo_stream action: "prepend", target: "chats"`      |
| Follow redirects                | `follow_redirect!`                                            |

### Naming Conventions
- **Files**: Use `[feature]_[behavior]_flow_test.rb` (e.g., `chat_create_flow_test.rb`).
- **Methods**: Use `[user or role] [performs flow] [via format or context] [and sees outcome]` (e.g., `"user creates a chat via HTML and sees it listed"`).

## 6. Flow Examples

### Authentication Flow
Test login → redirect → dashboard:
```ruby
test "user logs in via HTML and sees dashboard" do
  post sessions_url, params: { session: { email: @user.email, password: "password" } }
  assert_redirected_to chats_url(locale: I18n.locale)
  follow_redirect!
  assert_response :success
  assert_equal I18n.t("authentication.alerts.signed_in"), flash[:notice]
  assert_match @user.name, response.body
end
```

### Chat Creation Flow
Test create → redirect → render chat list:
```ruby
test "user creates a chat via HTML and sees it in sidebar" do
  post chats_url, params: { chat: { name: "New Chat" } }
  assert_redirected_to chats_url(locale: I18n.locale)
  follow_redirect!
  assert_response :success
  assert_equal I18n.t("helpers.created", model: Chat.model_name.human), flash[:notice]
  assert_match "New Chat", response.body
end
```

### Dashboard Rendering Flow
Test dashboard access → render chat list:
```ruby
test "user views dashboard and sees chat list" do
  chat = create(:chat, user: @user)
  get chats_url
  assert_response :success
  assert_match chat.name, response.body
end
```

**Notes**:
- Dashboard is `ChatsController#index`, rendering `_chat.html.erb` with `chats--chat-list`.
- Turbo Streams interact with `components--alert` for flash messages.
- Test validations in `docs/testing/model-testing-guidelines.md`.

## 7. Related Resources

- **Code**:
  - [Chats Controller](/app/controllers/chats_controller.rb)
  - [Turbo Stream View](/app/views/chats/create.turbo_stream.erb)
  - [Flash View](/app/views/shared/_flash.html.erb)
- **Guidelines**:
  - [Controller Testing](/docs/testing/controller-testing-guidelines.md)
  - [System Testing](/docs/testing/system-testing-guidelines.md)
  - [Model Testing](/docs/testing/model-testing-guidelines.md)
  - [Testing Overview](/docs/testing/README.md)
- **External**:
  - [Rails Guides — Integration Testing](https://guides.rubyonrails.org/testing.html#integration-testing)
  - [Turbo Stream Test Helpers](https://github.com/hotwired/turbo-rails/blob/main/test/assertions.rb)

---

Let's **Integrate** Tests Beautifully! ❤️
