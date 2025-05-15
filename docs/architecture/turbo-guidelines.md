---
title: "Turbo Guidelines"
description: "Concise guidelines for using Hotwire Turbo in this Rails application"
updated: "2025-05-15 10:23:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: xai-grok-3
    ai: true
  - username: openai-gpt-4o
    ai: true
pillar: "Architecture"
tags: ["rails", "turbo", "hotwire", "architecture"]
related_docs:
  - path: "/app/controllers/chats_controller.rb"
  - path: "/app/views/chats/create.turbo_stream.erb"
  - path: "/app/views/chats/_chat.html.erb"
  - path: "/docs/architecture/technical-overview.md"
  - path: "/docs/architecture/controller-guidelines.md"
  - path: "/docs/architecture/model-guidelines.md"
  - path: "/docs/architecture/stimulus-guidelines.md"
  - path: "/docs/architecture/stimulus-component-guidelines.md"
  - path: "/docs/architecture/stimulus-dispatch-guidelines.md"
  - path: "/docs/testing/controller-testing-guidelines.md"
  - path: "/docs/testing/integration-testing-guidelines.md"
  - path: "/docs/testing/model-testing-guidelines.md"
  - path: "/docs/testing/system-testing-guidelines.md"
---

# Turbo Guidelines

This guide provides a concise standard for using Hotwire Turbo in this Rails application, covering Turbo Drive, Frames, and Streams for **chat** UI features. It includes testing guidance for controller and integration tests.

## Table of Contents
- [Turbo Guidelines](#turbo-guidelines)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [1. Core Patterns](#1-core-patterns)
    - [Turbo Drive](#turbo-drive)
      - [Working with Forms](#working-with-forms)
      - [Link Options](#link-options)
    - [Turbo Frames](#turbo-frames)
      - [Lazy Loading](#lazy-loading)
    - [Turbo Streams](#turbo-streams)
      - [Stream Actions](#stream-actions)
  - [2. Testing Turbo](#2-testing-turbo)
    - [Testing Turbo Streams](#testing-turbo-streams)
  - [3. Conventions](#3-conventions)
  - [4. Related Resources](#4-related-resources)

## Overview

**Turbo is:**
- A Hotwire tool for fast navigation and dynamic updates without full page reloads.
- Used for Turbo Drive (navigation), Frames (targeted updates), and Streams (live changes).
- Key for chat UI (e.g., prepend chats, replace forms).


## 1. Core Patterns

### Turbo Drive
Links and forms auto-use Turbo Drive for fast navigation:
```erb
<%= link_to "Show Chat", chat_path(@chat) %>
<%= form_with model: @chat do |form| %>
  <%= form.text_field :name %>
  <%= form.submit %>
<% end %>
```

#### Working with Forms
Combine Turbo and Stimulus for enhanced form interactions:

```erb
<%= form_with model: chat, 
      data: {
        controller: "chats--chat-edit",
        action: "keydown.esc->chats--chat-edit#cancelEdit:prevent"
      } do |form| %>
  <!-- Form fields -->
<% end %>
```

#### Link Options
```erb
<!-- Disable Turbo for a specific link -->
<%= link_to "Open in new page", 
    chat_path(chat), 
    data: { turbo: false } %>

<!-- Prefetch link content on hover for faster loading -->
<%= link_to chat.name, 
    chat_path(chat), 
    data: { turbo_prefetch: true } %>

<!-- Force navigation to top-level (outside any frames) -->
<%= link_to chat.name, 
    chat_path(chat), 
    data: { turbo_frame: "_top" } %>
```

### Turbo Frames
Scope updates to a section:
```erb
<%= turbo_frame_tag dom_id(@chat) do %>
  <p><%= @chat.name %></p>
  <%= link_to "Edit", edit_chat_path(@chat), data: { turbo_frame: dom_id(@chat) } %>
<% end %>
```

#### Lazy Loading
Use the `src` attribute to load frame content after the page loads:

```erb
<%= turbo_frame_tag "chats_index", 
    src: chats_path,
    loading: "lazy" do %>
  Loading...
<% end %>
```

### Turbo Streams
Update multiple page parts:
```erb
<%= turbo_stream.prepend "chats", partial: "chat", locals: { chat: @chat } %>
<%= turbo_stream.update "chats_new", partial: "form_new", locals: { chat: Chat.new } %>
```

**Controller:**

```ruby
def create
  @chat = Chat.new(chat_params)
  respond_to do |format|
    if @chat.save
      format.turbo_stream
      format.html { redirect_to chats_url }
    else
      format.html { render :new }
    end
  end
end
```

#### Stream Actions
- `append`: Add content to the end of a container
- `prepend`: Add content to the beginning of a container
- `replace`: Replace the entire target element
- `update`: Replace the content inside the target
- `remove`: Remove the target element
- `before`: Insert content before the target
- `after`: Insert content after the target


## 2. Testing Turbo

Test Turbo interactions in controller and integration tests. See [README](/docs/testing/README.md) for more details.

### Testing Turbo Streams
Use `assert_turbo_stream` to verify stream actions (`prepend`, `replace`, `remove`).

**Controller Test:**

```ruby
test "user creates a chat via Turbo Stream" do
  login_as(@user)
  post chats_url(format: :turbo_stream), params: { chat: { name: "Turbo Chat" } }
  assert_turbo_stream action: "prepend", target: "chats"
  assert_turbo_stream action: "update", target: "chats_new"
end
```

**Integration Test:**

```ruby
test "user creates a chat via Turbo Stream and sees it listed" do
  login_as(@user)
  post chats_url(format: :turbo_stream), params: { chat: { name: "Turbo Chat" } }
  assert_turbo_stream action: "prepend", target: "chats"
  get chats_url
  assert_select "turbo-frame##{dom_id(Chat.last)}", text: "Turbo Chat"
end
```

**Notes**:
- Use `format: :turbo_stream` in requests.
- Test errors (e.g., `assert_response :unprocessable_entity` for invalid data).
- See [Controller Testing Guidelines](/docs/testing/controller-testing-guidelines.md) and [Integration Testing Guidelines](/docs/testing/integration-testing-guidelines.md).

## 3. Conventions
- **Stream Actions**: Use `prepend`, `replace`, `remove` for resources (e.g., `turbo_stream.prepend "resources"`).
- **Frame IDs**: Use `dom_id(@resource)` or semantic IDs (e.g., `dom_id(@chat)` → `"chat_123"`, or custom like `"chats_index"`).
- **Controllers**: Add `format.turbo_stream` in `respond_to`.
- **Tests**: Use `assert_turbo_stream` and `assert_select` for Turbo responses.
- **URLs**: Include `locale: I18n.locale` (e.g., `resources_url(locale: I18n.locale)`).


## 4. Related Resources
- **Code**:
  - [Chats Controller](/app/controllers/chats_controller.rb)
  - [Chat Turbo Stream View](/app/views/chats/create.turbo_stream.erb)
  - [Chat Partial](/app/views/chats/_chat.html.erb)
- **Guidelines**:
  - [Technical Overview](/docs/architecture/technical-overview.md)
  - [Controller Guidelines](/docs/architecture/controller-guidelines.md)
  - [Model Guidelines](/docs/architecture/model-guidelines.md)
  - [Stimulus Guidelines](/docs/architecture/stimulus-guidelines.md)
  - [Stimulus Component Guidelines](/docs/architecture/stimulus-component-guidelines.md)
  - [Stimulus Dispatch Guidelines](/docs/architecture/stimulus-dispatch-guidelines.md)
  - [Controller Testing Guidelines](/docs/testing/controller-testing-guidelines.md)
  - [Integration Testing Guidelines](/docs/testing/integration-testing-guidelines.md)
  - [Model Testing Guidelines](/docs/testing/model-testing-guidelines.md)
  - [System Testing Guidelines](/docs/testing/system-testing-guidelines.md)
- **External**:
  - [Turbo Handbook](https://turbo.hotwired.dev/handbook)
  - [Rails Guides](https://guides.rubyonrails.org)

---
Let's **Turbo** Beautifully! 🩵
