---
title: "Controller Guidelines"
description: "Best practices and patterns for working with controllers in this Rails application"
updated: "2025-05-15 10:15:00"
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
tags: ["rails", "controllers", "architecture"]
related_docs:
  - path: "/app/controllers/application_controller.rb"
  - path: "/app/controllers/concerns/authentication.rb"
  - path: "/app/controllers/chats_controller.rb"
  - path: "/docs/architecture/technical-overview.md"
  - path: "/docs/architecture/turbo-guidelines.md"
  - path: "/docs/testing/system-testing-guidelines.md"
  - path: "/docs/testing/integration-testing-guidelines.md"
---

# Controller Guidelines

This document outlines best practices for working with controllers in our Rails application. Controllers handle HTTP requests, orchestrate business logic, and render responses (HTML or Turbo Stream). These guidelines ensure consistency, security, and maintainability.

## Table of Contents
- [Controller Guidelines](#controller-guidelines)
  - [Table of Contents](#table-of-contents)
  - [1. Controller Organization](#1-controller-organization)
    - [Structure](#structure)
    - [RESTful Actions Order](#restful-actions-order)
  - [2. Authentication](#2-authentication)
    - [Allowing Unauthenticated Access](#allowing-unauthenticated-access)
    - [Rate Limiting](#rate-limiting)
  - [3. Strong Parameters](#3-strong-parameters)
    - [Using `expect`](#using-expect)
    - [Using `permit`](#using-permit)
  - [4. Response Handling](#4-response-handling)
    - [Turbo Stream Responses](#turbo-stream-responses)
    - [Response Status Codes](#response-status-codes)
  - [5. Flash Messages](#5-flash-messages)
  - [6. Current Object](#6-current-object)
  - [7. Variants](#7-variants)
  - [8. Error Handling](#8-error-handling)
  - [9. Custom Actions](#9-custom-actions)
  - [Summary](#summary)
  - [Testing Controllers](#testing-controllers)
  - [10. Related Resources](#10-related-resources)

## 1. Controller Organization

Controllers should follow a consistent structure and method order for readability and maintainability.

### Structure

Organize controllers with clear sections:

```ruby
class ApplicationController < ActionController::Base
  ## 1. Include Modules (loads first)
  include Authentication

  ## 2. Class-Level Configurations
  allow_browser versions: :modern
  add_flash_types :success, :warning

  ## 3. Before Actions (order matters)
  before_action :set_variant
  before_action :set_app_version
  helper_method :current_user
  around_action :switch_locale
  
  # Action methods
  
  private
    # Private methods
end
```

See `app/controllers/application_controller.rb` for the full implementation.

### RESTful Actions Order

Follow RESTful action order for consistency:

```ruby
def index
  # List resources
end

def show
  # Show a single resource
end

def new
  # Form for a new resource
end

def edit
  # Form to edit a resource
end

def create
  # Create a resource
end

def update
  # Update a resource
end

def destroy
  # Delete a resource
end
```


## 2. Authentication

Authentication is managed by the `Authentication` concern (see `app/controllers/concerns/authentication.rb`), which enforces user login by default.

Key methods:
- `authenticated?`: Checks if a user is logged in.
- `require_authentication`: Redirects unauthenticated users to the login page.
- `current_user`: Returns the authenticated user (memoized).
- `start_new_session_for(user)`: Creates a new session with signed cookies.
- `terminate_session`: Destroys the current session.

Example:
```ruby
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end
end
```

### Allowing Unauthenticated Access

Use `allow_unauthenticated_access` to skip authentication for specific actions:

```ruby
class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
end
```

See `app/controllers/sessions_controller.rb` for usage.

### Rate Limiting

Apply `rate_limit` to protect actions from abuse, especially for unauthenticated endpoints:

```ruby
class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: I18n.t("authentication.alerts.rate_limit_exceeded") }
end
```

Use rate limiting sparingly for high-risk actions like login attempts.


## 3. Strong Parameters

Our codebase prefers `params.expect` over the traditional `params.require(...).permit` for flat hashes.

> [!NOTE] [ActionController::Parameters#expect](https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-expect)
> 
### Using `expect`

`expect` ensures a specific nested parameter is present and raises `ActionController::ParameterMissing` if missing:

```ruby
def chat_params
  params.expect(chat: [:name])
end
```

See `app/controllers/chats_controller.rb` for usage.

### Using `permit`

Use `permit` for flat parameter hashes, especially with authentication methods like `authenticate_by`:

```ruby
def user_params
  params.permit(:email_address, :password)
end
```

See `app/controllers/sessions_controller.rb` for usage, as `authenticate_by` requires a hash, not an array.


## 4. Response Handling

Support both Turbo Stream and HTML responses to enable dynamic updates and fallback for non-JavaScript browsers.

### Turbo Stream Responses

Use `respond_to` with `turbo_stream` for dynamic updates and `html` for full page reloads:

```ruby
def create
  @chat = current_user.chats.new(chat_params)
  respond_to do |format|
    if @chat.save
      format.turbo_stream
      format.html { redirect_to chats_path, notice: t("helpers.created", model: Chat.model_name.human) }
    else
      format.turbo_stream { render :create_error, status: :unprocessable_entity }
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Turbo Stream templates (e.g., `app/views/chats/create.turbo_stream.erb`) update specific page elements without reloading. Use `flash.now` for flash messages in Turbo Stream responses:

```erb
<%= turbo_stream.replace(
    "dialog_flash_messages",
    partial: "shared/flash_messages",
    locals: { flash: flash, dialog_message: true }
) %>
```

See `app/controllers/chats_controller.rb` and `app/views/chats/update.turbo_stream.erb` for examples.

### Response Status Codes

Use appropriate HTTP status codes:
- `200 OK`: Successful reads (default for `render`).
- `302 Found`: Redirects after creates or updates (default for `redirect_to`).
- `303 See Other`: Redirects after deletes (e.g., `ChatsController#destroy`).
- `422 Unprocessable Entity`: Validation errors.

Example:
```ruby
def destroy
  flash.now[:success] = t("helpers.deleted", model: Chat.model_name.human)

  @chat.destroy!

  respond_to do |format|
    format.turbo_stream
    format.html { redirect_to chats_path, status: :see_other, notice: t("helpers.deleted", model: Chat.model_name.human) }
  end
end
```


## 5. Flash Messages

Use typed flash messages (`notice`, `alert`, `success`, `warning`) for consistent styling:

```ruby
add_flash_types :success, :warning
```

For redirects:
```ruby
redirect_to chats_path, notice: t("helpers.created", model: Chat.model_name.human)
```

For Turbo Stream responses, use `flash.now`:
```ruby
flash.now[:success] = t("helpers.updated", model: Chat.model_name.human)
```

See `app/controllers/chats_controller.rb` and `app/views/shared/flash_messages.html.erb` for implementation.


## 6. Current Object

The `Current` object (`app/models/current.rb`) stores request-local state, such as the current session and user:

```ruby
def current_user
  @current_user ||= Current.session&.user
end
```

This memoizes the user to avoid redundant queries and ensures consistent access across the request.


## 7. Variants

Set request variants (mobile/desktop) to customize rendering based on user agent:

```ruby
def set_variant
  request.variant = /Mobile|webOS/.match?(request.user_agent) ? :mobile : :desktop
end
```

See `app/controllers/application_controller.rb` for usage.


## 8. Error Handling

Handle errors with redirects and `alert` flash messages for unauthorized access or invalid input:

```ruby
def set_chat
  @chat = current_user.chats.find_by(id: params.expect(:id))
  redirect_to chats_path, alert: t("authorization.denied") unless @chat
end
```

See `app/controllers/chats_controller.rb` for examples.


## 9. Custom Actions

Define custom actions when needed, document their intent clearly, and keep them RESTful where possible.

```ruby
def drawer_list_item
  # Renders app/views/chats/drawer_list_item.html.erb
end
```

Document custom actions clearly and ensure they follow RESTful principles where possible. See `app/controllers/chats_controller.rb` for the `drawer_list_item` action.


## Summary

- Organize controllers with a consistent structure and RESTful action order.
- Use the `Authentication` concern for session management and `allow_unauthenticated_access` for public actions.
- Prefer `params.expect` for strong parameters, using `params.permit` when needed.
- Support Turbo Stream and HTML responses for dynamic updates and fallbacks.
- Use typed flash messages and `flash.now` for Turbo Stream.
- Leverage the `Current` object for request state.
- Set variants for responsive rendering and handle errors with redirects.
- Define custom actions sparingly and document their purpose.


## Testing Controllers

- Write system tests to verify user flows through controller actions (see `/docs/testing/system-testing-guidelines.md`).
- Use integration tests for multi-controller workflows (see `/docs/testing/integration-testing-guidelines.md`).


## 10. Related Resources
- **Code**:
  - [Application Controller](/app/controllers/application_controller.rb)
  - [Authentication Concern](/app/controllers/concerns/authentication.rb)
  - [Chats Controller](/app/controllers/chats_controller.rb)
- **Guidelines**:
  - [Technical Overview](/docs/architecture/technical-overview.md)
  - [Turbo Guidelines](/docs/architecture/turbo-guidelines.md)
  - [Model Guidelines](/docs/architecture/model-guidelines.md)
  - [Controller Testing Guidelines](/docs/testing/controller-testing-guidelines.md)
  - [Integration Testing Guidelines](/docs/testing/integration-testing-guidelines.md)
  - [Model Testing Guidelines](/docs/testing/model-testing-guidelines.md)
  - [System Testing Guidelines](/docs/testing/system-testing-guidelines.md)
- **External**:
  - [Action Controller Overview](https://guides.rubyonrails.org/action_controller_overview.html)
  - [Turbo Stream Documentation](https://turbo.hotwired.dev/handbook/streams)

---

Let's **Control** Beautifully! 🩵
