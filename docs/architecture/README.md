<!--
---
title: "Architecture Overview"
description: "Overview of system architecture, technical patterns, and UI/UX conventions"
updated: "2025-05-15 10:18:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: xai-grok-3
    ai: true
pillar: "Architecture"
tags: ["architecture", "rails", "hotwire", "sprint-001"]
related_docs:
  - path: "/docs/README.md"
  - path: "/docs/architecture/controller-guidelines.md"
  - path: "/docs/architecture/model-guidelines.md"
  - path: "/docs/architecture/stimulus-guidelines.md"
  - path: "/docs/architecture/stimulus-dispatch-guidelines.md"
  - path: "/docs/architecture/stimulus-component-guidelines.md"
  - path: "/docs/architecture/technical-overview.md"
  - path: "/docs/architecture/turbo-guidelines.md"
  - path: "/docs/architecture/diagrams/README.md"
  - path: "/docs/testing/README.md"
---
-->

# Architecture Overview

This folder defines the **system architecture, technical patterns, and UI/UX conventions** used across the project.

## How to Use This Folder

- Start with [Technical Overview](technical-overview.md) for a high-level understanding.
- Use the table below to find specific guidelines for controllers, models, Stimulus, Turbo, and more.
- See [Diagrams](/docs/diagrams/README.md) for system and UI diagrams.
- For testing, see [Testing Overview](../testing/README.md).

## Folder Overview

| Filename                                                               | Purpose                                                |
| ---------------------------------------------------------------------- | ------------------------------------------------------ |
| [`controller-guidelines.md`](controller-guidelines.md)                 | REST controller structure, Turbo response patterns     |
| [`model-guidelines.md`](model-guidelines.md)                           | Patterns for models, concerns, validations, etc.       |
| [`README.md`](README.md)                                               | Overview of the Architecture (this file ;)             |
| [`stimulus-component-guidelines.md`](stimulus-component-guidelines.md) | Stimulus component structure, DOM integration          |
| [`stimulus-dispatch-guidelines.md`](stimulus-dispatch-guidelines.md)   | Cross-controller communication with `dispatch()`       |
| [`stimulus-guidelines.md`](stimulus-guidelines.md)                     | Stimulus folder layout, controller structure           |
| [`technical-overview.md`](technical-overview.md)                       | Project-wide architecture, JS layout, deployment notes |
| [`turbo-guidelines.md`](turbo-guidelines.md)                           | Turbo Frames, Streams, and DOM structure               |

## Conventions

- **Controllers** are RESTful, scoped to domain logic, and extended via shared concerns
- **Models** are scoped to domain logic, and extended via shared concerns
- **Stimulus** follows a strict folder + naming scheme: `domain--name` → `folder/name_controller.js`
- **Views** use Turbo Streams and semantic HTML as first-class building blocks

Each section contains real-world examples from the app and recommended patterns.

## Architecture & Testing Integration

Our architecture is designed with testability as a first-class concern. Each component is structured to enable effective testing:

- **Models** separate concerns (validations, associations, business logic) for targeted testing
- **Controllers** use RESTful patterns and consistent response formats that can be reliably tested
- **Turbo Streams** use predictable DOM IDs and target patterns for system test verification
- **Stimulus Controllers** follow consistent patterns with explicit targets and values
- **Dom IDs and Selectors** follow conventions that make targeting in tests reliable

For a visual representation of how our architecture integrates with our testing strategy, see the [Architecture-Testing Integration diagram](/docs/diagrams/architecture-testing-integration.md).

The [Testing Overview](/docs/testing/README.md) and [Testing Pyramid](/docs/diagrams/testing-pyramid.md) provide more details on our testing approach.

## Related Resources
- **Code**:
  - [Controllers](/app/controllers/)
  - [Models](/app/models/)
  - [Stimulus Controllers](/app/javascript/controllers/)
- **Guidelines**:
  - [Technical Overview](/docs/architecture/technical-overview.md)
  - [Controller Guidelines](/docs/architecture/controller-guidelines.md)
  - [Model Guidelines](/docs/architecture/model-guidelines.md)
  - [Stimulus Guidelines](/docs/architecture/stimulus-guidelines.md)
  - [Stimulus Component Guidelines](/docs/architecture/stimulus-component-guidelines.md)
  - [Stimulus Dispatch Guidelines](/docs/architecture/stimulus-dispatch-guidelines.md)
  - [Turbo Guidelines](/docs/architecture/turbo-guidelines.md)
  - [Diagrams](/docs/diagrams/README.md)
  - [Testing Overview](/docs/testing/README.md)
- **External**:
  - [Rails Guides](https://guides.rubyonrails.org)
  - [Hotwire Docs](https://hotwired.dev/)
  - [TailwindCSS Docs](https://tailwindcss.com/docs)

---

Let's **Build** Beautifully! 🩵