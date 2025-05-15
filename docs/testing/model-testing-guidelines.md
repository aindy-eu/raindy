---
title: "Model Testing Guidelines"
description: "Standards for writing Minitest specs for Rails models in a Rails 8 chat application"
updated: "2025-05-15 10:25:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: xai-grok-3
    ai: true
pillar: "Testing"
tags: ["testing", "minitest", "model", "factory-bot", "concerns"]
related_docs:
  - path: "/app/models/chat.rb"
  - path: "/app/models/user.rb"
  - path: "/docs/architecture/model-guidelines.md"
  - path: "/docs/testing/controller-testing-guidelines.md"
  - path: "/docs/testing/integration-testing-guidelines.md"
  - path: "/docs/testing/system-testing-guidelines.md"
---

# Model Testing Guidelines

This guide defines standards for testing Rails models (`User`, `Chat`, `Session`) in this Rails 8 chat application using Minitest. Model tests verify isolated business logic, including validations, associations, sanitization, authentication, normalizers, callbacks, and scopes, ensuring reliability for controllers (`app/controllers/chats_controller.rb`) and Turbo Stream views (`app/views/chats/_chat.html.erb`). 

They complement controller tests ([Controller Testing Guidelines](/docs/testing/controller-testing-guidelines.md)) for HTTP actions, integration tests ([Integration Testing Guidelines](/docs/testing/integration-testing-guidelines.md)) for multi-step flows, and system tests ([System Testing Guidelines](/docs/testing/system-testing-guidelines.md)) for UI interactions.

## Table of Contents
- [Model Testing Guidelines](#model-testing-guidelines)
  - [Table of Contents](#table-of-contents)
  - [1. Overview](#1-overview)
  - [2. Quick Start](#2-quick-start)
  - [3. Folder Structure](#3-folder-structure)
  - [4. When to Use Model Tests](#4-when-to-use-model-tests)
  - [5. Common Patterns](#5-common-patterns)
    - [Validations](#validations)
    - [Associations](#associations)
    - [SanitizationConcern](#sanitizationconcern)
    - [Authentication](#authentication)
    - [Normalizers](#normalizers)
    - [Callbacks](#callbacks)
    - [Scopes](#scopes)
  - [6. Conventions](#6-conventions)
    - [Naming Conventions](#naming-conventions)
  - [7. Concern Coverage (Shared Behavior Tests)](#7-concern-coverage-shared-behavior-tests)
  - [8. Model Examples](#8-model-examples)
    - [User](#user)
    - [Chat](#chat)
  - [9. Related Resources](#9-related-resources)

## 1. Overview

Model tests verify business logic for `User`, `Chat`, and `Session` models, focusing on:
- **Validations**: Presence, format, uniqueness (e.g., `Chat#name` presence, `User#email_address` format).
- **Associations**: `User has_many :chats`, `Chat belongs_to :user`, `User has_many :sessions`.
- **Sanitization**: HTML tag removal via `SanitizationConcern` for safe display in `chats--chat-list`.
- **Authentication**: `User` password via `has_secure_password`.
- **Normalizers**: Data cleanup (e.g., stripping whitespace from `Chat#name`, lowercasing `User#email_address`).
- **Callbacks**: Behaviors like UUID generation via `UuidConcern`.
- **Scopes**: Query logic (e.g., `Chat.default_scope` for descending order).

Tests are fast, database-light (using `build` over `create` where possible), and use FactoryBot for setup. They ensure model reliability for controllers and Turbo Stream views, supporting accessibility with `I18n.t` error messages (`shared/_flash.html.erb`).

## 2. Quick Start

1. **Create a Test File**: Name it `[concern]_test.rb` (e.g., `validations_test.rb`).
   ```ruby
   # test/models/chat/validations_test.rb
   class ChatValidationsTest < ActiveSupport::TestCase
   ```

2. **Set Up**: Use FactoryBot for test data.
   ```ruby
   setup do
     @chat = build(:chat)
   end
   ```

3. **Write a Test**: Use the `[subject] [behavior] [with condition]` naming format.
   ```ruby
   test "chat is valid with required name" do
     chat = build(:chat, name: "My Chat")
     assert chat.valid?
   end
   
   test "user fails to create chat with blank name" do
     chat = build(:chat, name: "")
     assert_not chat.valid?
     assert_includes chat.errors[:name], I18n.t("activerecord.errors.models.chat.attributes.name.blank")
   end
   ```

   **Test Naming Conventions:**
   - **Preferred**: `[subject] [behavior] [with condition]` - This pattern is more aligned with Minitest's assertion-style testing and focuses on the component being tested and its behavior.
   - **Less Preferred for Model Tests**: `[user or role] [performs action] [and sees outcome]` - This pattern is more appropriate for system/feature tests or BDD-style frameworks like RSpec.
   
   The subject-behavior-condition pattern is preferred for model tests because:
   - It directly describes what's being tested (the subject)
   - It clearly states the expected behavior
   - It specifies the conditions under which the behavior should occur
   - It aligns with Minitest's more direct testing approach

4. **Test Concerns**:
   ```ruby
   test "chat sanitizes HTML tags from name" do
     chat = build(:chat, name: "<script>alert('XSS')</script>")
     chat.valid?
     assert_equal "alert('XSS')", chat.name
   end
   ```
5. **Run Tests**: Use `bin/rails test test/models`.

**Note**: Use `build` instead of `create` when you want to minimize database interactions.

## 3. Folder Structure

```plaintext
test/models/
├── user/
│   ├── associations_test.rb
│   ├── auth_test.rb
│   ├── callbacks_test.rb
│   ├── normalizers_test.rb
│   ├── validations_test.rb
│   └── user_test.rb
├── chat/
│   ├── associations_test.rb
│   ├── callbacks_test.rb
│   ├── normalizers_test.rb
│   ├── scopes_test.rb
│   ├── validations_test.rb
│   └── chat_test.rb
├── concerns/
│   ├── sanitization_concern_test.rb
│   ├── strict_validation_concern_test.rb
│   └── uuid_concern_test.rb
└── chat_test.rb            # High-level chat tests
└── user_test.rb            # High-level user tests
```

- **Model Folders**: Group tests by model (e.g., `user/`, `chat/`, `session/`).
- **Concerns**: Test shared behaviors in `concerns/` (e.g., `sanitization_concern_test.rb`).
- **High-Level Tests**: Use `<model>_test.rb` for miscellaneous tests (e.g., `user_test.rb`).

## 4. When to Use Model Tests

| Use If...                                           | Don't Use If...                                  |
| --------------------------------------------------- | ------------------------------------------------ |
| Testing validations (e.g., `Chat` name presence)    | Testing HTTP responses (use controller tests)    |
| Testing associations (e.g., `User has_many :chats`) | Testing UI interactions (use system tests)       |
| Testing sanitization (e.g., HTML tag removal)       | Testing multi-step flows (use integration tests) |
| Testing authentication (e.g., password validation)  | Testing rendering or redirects                   |
| Testing normalizers (e.g., stripping whitespace)    | Testing controller actions                       |
| Testing callbacks (e.g., before_validation)         |                                                  |
| Testing scopes (e.g., default_scope)                |                                                  |

## 5. Common Patterns

### Validations
- Use `build(:model)` to avoid database hits unless persistence is tested.
- Test invalid states with `assert_not valid?` and check errors with `assert_includes`.
- Example:
  ```ruby
  test "chat name cannot be blank" do
    chat = build(:chat, name: "")
    assert_not chat.valid?
    assert_includes chat.errors[:name], I18n.t("activerecord.errors.models.chat.attributes.name.blank")
  end
  ```

### Associations
Verify association definitions and behaviors like `dependent: :destroy`.
```ruby
test "user deletes account and destroys associated chats" do
  user = create(:user, :with_3_chats)
  assert_difference "Chat.count", -3 do
    user.destroy
  end
end

test "user deletes account and destroys associated sessions" do
  user = create(:user)
  create(:session, user: user)
  assert_difference "Session.count", -1 do
    user.destroy
  end
end
```

### SanitizationConcern
Test HTML tag removal for models using `SanitizationConcern`.
```ruby
test "user creates chat with sanitized name" do
  @chat.name = "<script>alert('XSS')</script>"
  @chat.valid?
  assert_equal "alert('XSS')", @chat.name
end

test "user updates profile with sanitized name" do
  user = build(:user, name: "<b>John Doe</b>")
  user.valid?
  assert_equal "John Doe", user.name
end
```

### Authentication

- Test `has_secure_password` functionality for `User`.
- Example:
  ```ruby
  test "user authenticates with valid password" do
    user = create(:user, password: "password123")
    assert user.authenticate("password123")
    assert_not user.authenticate("wrong")
  end
  ```

### Normalizers

- Test Rails 7+ normalizers for data cleanup. (e.g., whitespace, case).

- Example:
  ```ruby
  test "chat normalizes name by stripping whitespace" do
    chat = build(:chat, name: "  My Chat  ")
    assert_equal "My Chat", chat.name
  end
  
  test "user normalizes email address to lowercase" do
    user = build(:user, email_address: "USER@EXAMPLE.COM")
    assert_equal "user@example.com", user.email_address
  end
  ```

### Callbacks

- Test callback effects on the model.
- Example:
  ```ruby
  test "chat has uuid before validation" do
    chat = build(:chat)
    assert_nil chat.uuid
    chat.valid?
    assert_not_nil chat.uuid
  end
  ```

### Scopes
Test query logic like `Chat.default_scope` or custom scopes.
```ruby
test "user sees chats ordered by created_at descending" do
  older_chat = create(:chat, user: @user, created_at: 2.days.ago)
  newer_chat = create(:chat, user: @user, created_at: 1.day.ago)
  assert_equal [newer_chat, older_chat], Chat.all.to_a
end

test "user sees chats in ascending order with asc scope" do
  older_chat = create(:chat, user: @user, created_at: 2.days.ago)
  newer_chat = create(:chat, user: @user, created_at: 1.day.ago)
  assert_equal [older_chat, newer_chat], Chat.asc.to_a
end
```

## 6. Conventions

| Practice                           | Example                                                          |
| ---------------------------------- | ---------------------------------------------------------------- |
| Use FactoryBot                     | `build(:chat, name: "Test Chat")`                                |
| Use `build` over `create`          | `build(:user)` is faster than `create(:user)`                    |
| Use `I18n.t` for error messages    | `assert_includes errors[:name], I18n.t("errors.messages.blank")` |
| Use descriptive test names         | `"chat name cannot be blank"`                                    |
| Test one concept per test          | Separate validation tests from association tests                 |
| Use `assert_difference` for counts | `assert_difference "Chat.count", -1 do`                          |
| Debug with `binding.irb`           | Add `binding.irb` for debugging, remove before committing        |

### Naming Conventions
- **Files**: `[concern]_test.rb` (e.g., `validations_test.rb`) or `<model>_test.rb` in `test/models/[model]/` or `test/models/concerns/`.
- **Methods**: `[subject] [behavior] [with condition]` (e.g., `"chat is valid with required name"`).
  - Focus on the subject being tested and its expected behavior
  - Specify the conditions under which the test applies
  - Use present tense and clear verbs
  - Include context (e.g., "with blank name") for clarity
  - Avoid vague terms like "should"
  
  **Note**: The `[user or role] [performs action] [and sees outcome]` pattern is more appropriate for system/feature tests or BDD frameworks like RSpec, but less preferred for model tests.

## 7. Concern Coverage (Shared Behavior Tests)

| File                                | Purpose                             |
| ----------------------------------- | ----------------------------------- |
| `sanitization_concern_test.rb`      | Ensures HTML tags are stripped      |
| `strict_validation_concern_test.rb` | Validates forbidden characters      |
| `uuid_concern_test.rb`              | Ensures UUIDs are assigned pre-save |


## 8. Model Examples

Unique model behaviors not covered in Common Patterns.

### User
```ruby
test "user signs up with valid email format" do
  user = build(:user, email_address: "user@example.com")
  assert user.valid?
end

test "user fails to sign up with invalid email format" do
  user = build(:user, email_address: "invalid-email")
  assert_not user.valid?
  assert_includes user.errors[:email_address], I18n.t("errors.messages.invalid_email")
end
```

### Chat
```ruby
test "user fails to create chat with name exceeding maximum length" do
  chat = build(:chat, name: "A" * 256)
  assert_not chat.valid?
  assert_includes chat.errors[:name], I18n.t("errors.messages.too_long", count: Constants::MAX_NAME_LENGTH)
end
```

## 9. Related Resources

- **Code**:
  - [Chat Model](/app/models/chat.rb)
  - [User Model](/app/models/user.rb)
  - [Sanitization Concern](/app/models/concerns/sanitization_concern.rb)
  - [Strict Validation Concern](/app/models/concerns/strict_validation_concern.rb)
  - [UUID Concern](/app/models/concerns/uuid_concern.rb)
- **Guidelines**:
  - [Controller Testing](/docs/testing/controller-testing-guidelines.md)
  - [Integration Testing](/docs/testing/integration-testing-guidelines.md)
  - [System Testing](/docs/testing/system-testing-guidelines.md)
  - [Model Guidelines](/docs/architecture/model-guidelines.md)
  - [Testing Overview](/docs/testing/README.md)
- **External**:
  - [Minitest Documentation](https://github.com/minitest/minitest)
  - [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
  - [FactoryBot Documentation](https://github.com/thoughtbot/factory_bot)

---

Let's **Model** Tests Beautifully! ❤️