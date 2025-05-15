---
title: "Testing Overview"
description: "An overview of the testing strategy for this chat application"
updated: "2025-05-15 10:26:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: xai-grok-3
    ai: true
  - username: cursor-anthropic-claude-3-7-sonnet
    ai: true
category: "Testing"
tags: ["testing", "overview", "minitest", "capybara", "turbo-stream"]
related_docs:
  - path: "/docs/testing/controller-testing-guidelines.md"
  - path: "/docs/testing/integration-testing-guidelines.md"
  - path: "/docs/testing/model-testing-guidelines.md"
  - path: "/docs/testing/system-testing-guidelines.md"
  - path: "/docs/testing/testing-glossary.md"
---

# Testing Overview

This guide provides a high-level overview of the testing strategy for this Rails 8 chat application, using **Minitest** for all test types: **model**, **controller**, **integration**, and **system** (with **Capybara**). It introduces the testing philosophy, folder structure, and naming conventions, with detailed guidance in specific guidelines. For definitions of testing terms (e.g., **FactoryBot**, **assertion**, **WCAG**), see the [Testing Glossary](/docs/testing/testing-glossary.md).


## Table of Contents
- [Testing Overview](#testing-overview)
  - [Table of Contents](#table-of-contents)
  - [1. Overview](#1-overview)
  - [2. Philosophy](#2-philosophy)
  - [3. Folder Structure](#3-folder-structure)
  - [4. Naming Conventions](#4-naming-conventions)
  - [5. Running Tests](#5-running-tests)
  - [6. Related Resources](#6-related-resources)

## 1. Overview

This chat application uses a comprehensive testing strategy to ensure reliability and usability, covering:

- **Model Tests**: Verify **validations** (e.g., `Chat` name presence) and associations (e.g., `User has_many :chats`). See [Model Testing Guidelines](/docs/testing/model-testing-guidelines.md).
- **Controller Tests**: Test single HTTP actions (e.g., `ChatsController#create`) and **Turbo Stream** responses. See [Controller Testing Guidelines](/docs/testing/controller-testing-guidelines.md).
- **Integration Tests**: Verify multi-step HTTP flows (e.g., sign-in to dashboard). See [Integration Testing Guidelines](/docs/testing/integration-testing-guidelines.md).
- **System Tests**: Simulate **UI interactions** (e.g., creating chats, **keyboard navigation**) using **Capybara** in a **headless browser**. See [System Testing Guidelines](/docs/testing/system-testing-guidelines.md).

Tests run in **CI/CD** pipelines, using **FactoryBot** for data setup and **test helpers** to reduce duplication.

The [Testing Pyramid diagram](/docs/diagrams/testing-pyramid.md) visualizes this approach, showing how we have more, faster tests at the model level and fewer, comprehensive tests at the system level.

## 2. Philosophy
- **Test by Concern**: Separate tests for **validations**, associations, HTTP actions, and UI interactions for clarity.
- **System-First for UI**: Prioritize **system tests** for **UI interactions**, supported by **controller** and **integration tests** for HTTP behavior.
- **FactoryBot Over Fixtures**: Use **FactoryBot** (e.g., `create(:user)`) for dynamic test data.
- **Helper-Driven**: Use **test helpers** (e.g., for authentication, chat creation) to simplify setup and assertions.
- **Accessibility**: Ensure **WCAG** compliance in **system tests** (e.g., ARIA attributes, focus management).


## 3. Folder Structure

```plaintext
test/
├── controllers/
│   ├── chats/
│   └── auth/
├── factories/
├── fixtures/
├── helpers/
├── integration/
│   ├── auth/
│   └── chats/
├── mailers/
│   ├── previews/
│   └── tests/
├── models/
│   ├── chat/
│   ├── concerns/
│   └── user/
├── system/
│   ├── auth/
│   ├── chats/
│   ├── stimulus/
│   │   └── components/
├── test_helpers/
│   ├── chats/
│   │   └── chat_helper.rb
│   ├── shared/
│   │   └── flash_helper.rb
│   ├── system/
│   │   ├── authentication_helper.rb
│   │   ├── drawer_helper.rb
│   │   ├── dropdown_helper.rb
│   │   └── keyboard_navigation_helper.rb
│   └── authentication_helper.rb
├── views/
│   └── shared/
│       └── flash_messages_view_test.erb
```

- **controllers/**: HTTP and **Turbo Stream** tests for `ChatsController`.
- **integration/**: Cross-controller flows (e.g., sign-in to chat creation).
- **models/**: **Validations** and associations for `Chat`, `User`.
- **system/**: **Capybara** tests for **UI interactions**.
- **test_helpers/**: **Test helpers** for authentication, chat actions, and UI navigation.
- **factories/**: **FactoryBot** definitions.
- **views/**: **View** tests for views.


## 4. Naming Conventions

- **[Model Tests](/docs/testing/model-testing-guidelines.md#3-folder-conventions)**: `[concern]_test.rb` (e.g., `validations_test.rb`), methods like `chat is valid with required name`.
- **[Controller Tests](/docs/testing/controller-testing-guidelines.md)**: `[action]_test.rb` (e.g., `create_test.rb`), methods like `user creates chat via HTML`.
- **[Integration Tests](/docs/testing/integration-testing-guidelines.md)**: `[behavior]_flow_test.rb` (e.g., `create_flow_test.rb`), methods like `user creates chat and sees flash`.
- **[System Tests](/docs/testing/system-testing-guidelines.md)**: `[feature]_[behavior]_test.rb` (e.g., `chats/create_test.rb`), methods like `user creates chat and sees it listed`.
- **Test Helpers**: `[domain]_helper.rb` (e.g., `authentication_helper.rb`), methods like `sign_in`, `assert_chat_created`.

See specific guidelines for detailed conventions.

## 5. Running Tests

```bash
# Run all tests
bin/rails test

# Run all system tests this way 
# !Important for CI and headless browser testing
find test/system/ -name '*_test.rb' | xargs -n 1 bin/rails test

# Run a single file
bin/rails test test/system/chats/create_test.rb
```

**Debugging Tip**: Use `binding.irb` in **model** tests or `slow_down(duration = 1)` in **system tests** for animations.

## 6. Related Resources

- **Code**:
  - [Chats Controller](/app/controllers/chats_controller.rb)
  - [Chat List View](/app/views/chats/_chat.html.erb)
  - [Turbo Stream View](/app/views/chats/create.turbo_stream.erb)
- **Guidelines**:
  - [Testing Glossary](/docs/testing/testing-glossary.md)
  - [Model Testing](/docs/testing/model-testing-guidelines.md)
  - [Controller Testing](/docs/testing/controller-testing-guidelines.md)
  - [Integration Testing](/docs/testing/integration-testing-guidelines.md)
  - [System Testing](/docs/testing/system-testing-guidelines.md)
- **External**:
  - [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
  - [Capybara Documentation](https://github.com/teamcapybara/capybara)
  - [Minitest Documentation](https://github.com/minitest/minitest)
  - [FactoryBot Documentation](https://github.com/thoughtbot/factory_bot)
---

Let's **Test** Beautifully! ❤️