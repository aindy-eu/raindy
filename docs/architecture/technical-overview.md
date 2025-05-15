<!--
---
title: "Technical Overview"
description: "Overview of the technical architecture and conventions for this Rails 8 application"
updated: "2025-05-15 10:22:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: xai-grok-3
    ai: true
tags: ["rails", "hotwire", "tailwind", "architecture"]
related_docs:
  - path: "/app/controllers/chats_controller.rb"
  - path: "/app/models/chat.rb"
  - path: "/app/models/user.rb"
  - path: "/app/assets/stylesheets/application.css"
  - path: "/app/assets/tailwind/"
  - path: "/app/javascript/controllers/"
  - path: "/config/importmap.rb"
  - path: "/Gemfile"
  - path: "/docs/architecture/README.md"
  - path: "/docs/architecture/model-guidelines.md"
  - path: "/docs/architecture/controller-guidelines.md"
  - path: "/docs/architecture/stimulus-guidelines.md"
  - path: "/docs/architecture/stimulus-component-guidelines.md"
  - path: "/docs/architecture/stimulus-dispatch-guidelines.md"
  - path: "/docs/architecture/turbo-guidelines.md"
  - path: "/docs/testing/model-testing-guidelines.md"
  - path: "/docs/testing/system-testing-guidelines.md"
  - path: "/docs/testing/integration-testing-guidelines.md"
---
-->

# Technical Overview

This document provides a high-level overview of the technical architecture and conventions for this Rails 8 application, a real-time chat platform emphasizing dynamic UI, modularity, and developer-friendly setup. It covers the technology stack, architectural patterns, asset pipeline, frontend, security, and development workflow. Broader architectural details are in `docs/architecture/readme.md`.

## Table of Contents
- [Technical Overview](#technical-overview)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
  - [2. Technology Stack](#2-technology-stack)
  - [3. Architectural Patterns](#3-architectural-patterns)
  - [4. Asset Pipeline and Frontend](#4-asset-pipeline-and-frontend)
    - [Propshaft](#propshaft)
    - [TailwindCSS](#tailwindcss)
    - [Import Maps](#import-maps)
  - [5. Security Practices](#5-security-practices)
  - [6. Development Workflow](#6-development-workflow)
    - [Prerequisites](#prerequisites)
    - [Setup Steps](#setup-steps)
  - [7. Testing Overview](#7-testing-overview)
  - [8. Deployment Overview](#8-deployment-overview)

## 1. Introduction

This application is a chat application built with Rails 8, Hotwire (Turbo and Stimulus), TailwindCSS, and SQLite. It uses modern Rails features like Propshaft and import maps for efficient asset delivery and JavaScript integration. The architecture prioritizes fast, dynamic user interactions and secure, maintainable code.

See `app/controllers/chats_controller.rb` for a key example of the app's structure.


## 2. Technology Stack

The application uses the following technologies:

- **Ruby 3.4.1**: Managed via `mise` for consistent versioning (`.mise.toml`).
- **Rails 8.0.2**: MVC framework with UUID primary keys and modern defaults.
- **SQLite 2.6.0**: Lightweight database for development and production.
- **Hotwire**:
  - **Turbo 2.0.13**: Dynamic UI with Streams and Frames for chat updates.
  - **Stimulus 1.3.4**: Lightweight JavaScript for form interactions.
- **TailwindCSS 4.2.3**: Utility-first CSS with custom components.
- **Propshaft 1.1.0**: Modern asset pipeline for efficient delivery.
- **Import Maps 2.1.0**: ESM JavaScript delivery without bundlers (`importmap-rails`).
- **Authentication**: `bcrypt 3.1.20` for secure passwords with `has_secure_password`.
- **Solid Gems**:
  - **Solid Cache 1.0.7**: Database-backed caching.
  - **Solid Queue 1.1.5**: Background job processing.
- **PWA**: Progressive web app support with manifest (`app/pwa/`).
- **Kamal 2.6.0**: Containerized deployment tool.
- **Thruster 0.1.13**: HTTP caching and compression for Puma.
- **Active Storage**: Local file storage for uploads.

See `Gemfile` and `Gemfile.lock` for the full dependency list.


## 3. Architectural Patterns

The application follows these core patterns:

- **MVC with Hotwire**: RESTful controllers (`ChatsController`) use Turbo Streams (`app/views/chats/create.turbo_stream.erb`) for dynamic updates and Stimulus (`app/javascript/controllers/chats/`) for interactivity.
- **UUIDs**: String primary keys via `UuidConcern` for all models (`config.generators`).
- **Authentication**: Custom `Authentication` concern with signed cookies and rate limiting (`app/controllers/concerns/authentication.rb`).
- **Concerns**: Reusable logic for models (`SanitizationConcern`, `StrictValidationConcern`) and controllers (`Authentication`).
- **I18n**: Locale switching via `switch_locale` in `ApplicationController`.
- **Routing**: RESTful routes with PWA manifest support (`config/routes.rb`).

Example: `app/models/chat.rb` uses `UuidConcern` and `SanitizationConcern` for secure, unique chat records.


## 4. Asset Pipeline and Frontend

### Propshaft
Propshaft delivers assets efficiently without preprocessing:
- **Structure**: `app/assets/stylesheets/` (CSS), `app/assets/builds/` (Tailwind output), `app/assets/tailwind/` (custom styles).
- **Usage**: Serves `application.css` and JavaScript via import maps.

See `app/assets/stylesheets/application.css`.

### TailwindCSS
TailwindCSS provides styling with custom tokens and components:
- **Configuration**: `tailwind.config.js` defines breakpoints and themes.
- **Components**: Custom classes (e.g., `.btn-primary`) in `app/assets/tailwind/application.css`.
- **Views**: Applied in templates (e.g., `class="group flex items-center"` in `app/views/chats/_chat.html.erb`).

### Import Maps
Import maps manage JavaScript without bundlers:
- **Structure**: `app/javascript/controllers/` for Stimulus controllers, `app/javascript/utils/` for utilities.
- **Pinned**: `turbo.min.js`, `stimulus.min.js` (`config/importmap.rb`).


## 5. Security Practices

The application prioritizes security:
- **Authentication**: Rate limiting in `SessionsController`, `bcrypt` passwords in `User` model.
- **Sanitization**: `SanitizationConcern` prevents XSS by escaping characters (e.g., `&` to `&`).
- **Strong Parameters**: `params.expect`/`params.permit` in controllers (`ChatsController`).
- **Static Analysis**: `brakeman` for vulnerability checks (`Gemfile`).

See `app/models/concerns/sanitization_concern.rb` for sanitization logic.


## 6. Development Workflow

### Prerequisites
- Ruby 3.4.1 (use [`mise`](https://mise.jdx.dev/) or your preferred version manager)

### Setup Steps
1. **Install Tools and Dependencies**:
   ```bash
   mise install        # Installs Ruby 3.4.1
   bin/setup           # Installs gems, sets up SQLite DB, runs migrations
   ```
2. **Seed the Database**:
   Change my 'foo@bar.de' to your email address and seed the database:
   ```bash
   bin/rails db:seed
   ```
3. **Start Development Server**:
   ```bash
   bin/dev             # Runs Rails and TailwindCSS watcher
   ```
   Open [http://localhost:3044](http://localhost:3044).


**Notes**:
- `bin/dev` includes `tailwindcss --watch` for CSS compilation.
- The app runs on port **3044** instead of Rails' default 3000 to avoid conflicts with other Rails applications.
- Environment variables may be needed for `solid_cache` or Active Storage.


## 7. Testing Overview
Testing uses `capybara`, `selenium-webdriver`, and `factory_bot_rails` for system and integration tests. See `docs/testing/controller-testing-guidelines.md` for details.


## 8. Deployment Overview
Deployment uses `kamal`