---
title: "Project Documentation"
description: "Documentation for this Rails 8 application"
updated: "2025-05-15 10:28:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: xai-grok-3
    ai: true
category: "Documentation"
tags: ["documentation", "rails", "turbo", "stimulus", "testing"]
related_docs:
  - path: "/docs/architecture/README.md"
  - path: "/docs/diagrams/README.md"
  - path: "/docs/testing/README.md"
---

# Project Documentation

Welcome to the documentation for raindy, a simple chat application that enables users to create, manage, and interact with conversations in real-time. Built with Rails 8, Turbo Streams, and Stimulus controllers.  

This repository provides guides for architecture, testing, and visualizations to support development.  
The app features accessible UI with keyboard navigation, Turbo-driven updates, and testing with Minitest and Capybara. 

## Table of Contents
- [Project Documentation](#project-documentation)
  - [Table of Contents](#table-of-contents)
  - [1. Overview](#1-overview)
  - [2. Documentation Structure](#2-documentation-structure)
  - [3. Getting Started](#3-getting-started)
  - [4. Related Resources](#4-related-resources)

## 1. Overview

- **Turbo Streams** for dynamic updates (e.g., `app/views/chats/create.turbo_stream.erb`).
- **Stimulus** for interactive UI (e.g., `chats--chat-list`, `components--drawer`).
- **ActiveRecord** models (`Chat`, `User`) with validations and sanitization.
- **Accessibility** via ARIA attributes and WCAG compliance.

This documentation covers architecture, testing, and diagrams to guide developers. The term `resource` in some guidelines refers to models like `chat` or `user`.

## 2. Documentation Structure

The `docs/` folder organizes documentation into three main sections:

| Section          | Purpose                                                                               | Key Documents                                                                                                                                                                                                                                                                                                                                                                  |
| ---------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Architecture** | Guides for designing controllers, models, Stimulus, and Turbo components              | [Architecture README](/docs/architecture/README.md), [Model Guidelines](/docs/architecture/model-guidelines.md), [Stimulus Guidelines](/docs/architecture/stimulus-guidelines.md), [Turbo Guidelines](/docs/architecture/turbo-guidelines.md)                                                                                                                                      |
| **Diagrams**     | Mermaid visualizations of data models and app architecture                            | [Diagrams README](/docs/diagrams/README.md), [Data Model](/docs/diagrams/data-model.md), [App Architecture](/docs/diagrams/app-architecture.md), [Testing Pyramid](/docs/diagrams/testing-pyramid.md), [Architecture-Testing Integration](/docs/diagrams/architecture-testing-integration.md)                                                                                    |
| **Testing**      | Minitest and Capybara guidelines for model, controller, integration, and system tests | [Testing README](/docs/testing/README.md), [Model Testing](/docs/testing/model-testing-guidelines.md), [Controller Testing](/docs/testing/controller-testing-guidelines.md), [Integration Testing](/docs/testing/integration-testing-guidelines.md), [System Testing](/docs/testing/system-testing-guidelines.md), [Testing Glossary](/docs/testing/testing-glossary.md) |

## 3. Getting Started

To explore the documentation:
1. **Start with Architecture**: Review [Model Guidelines](/docs/architecture/model-guidelines.md) for `Chat` and `User` models or [Turbo Guidelines](/docs/architecture/turbo-guidelines.md) for Turbo Streams.
2. **Visualize with Diagrams**: Use [Data Model](/docs/diagrams/data-model.md) to understand database relationships and [Testing Pyramid](/docs/diagrams/testing-pyramid.md) to understand our testing approach.
3. **Dive into Testing**: Follow [System Testing Guidelines](/docs/testing/system-testing-guidelines.md) for UI testing with Capybara.

The diagram below shows how our architecture components integrate with our testing strategy:

[Architecture-Testing Integration](/docs/diagrams/architecture-testing-integration.md)

The [Testing Glossary](/docs/testing/testing-glossary.md) defines terms like FactoryBot, assertion, and WCAG.

## 4. Related Resources

- **Code**:
  - [Chats Controller](/app/controllers/chats_controller.rb)
  - [Chat List View](/app/views/chats/_chat.html.erb)
  - [Turbo Stream View](/app/views/chats/create.turbo_stream.erb)
- **Guidelines**:
  - [Testing Glossary](/docs/testing/testing-glossary.md)
  - [Diagrams README](/docs/diagrams/README.md)
  - [Architecture README](/docs/architecture/README.md)
- **External**:
  - [Rails Documentation](https://guides.rubyonrails.org/)
  - [Turbo Documentation](https://turbo.hotwired.dev/)
  - [Stimulus Documentation](https://stimulus.hotwired.dev/)
  - [Mermaid Documentation](https://mermaid-js.github.io/mermaid/)

---

Let's **Develop** Beautifully! 🩵🧡❤️