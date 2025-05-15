<!--
---
title: "Rails Application Architecture"
description: "Mermaid diagram illustrating the Rails application architecture and component relationships"
updated: "2025-05-15 10:24:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: cursor-anthropic-claude-3-7-sonnet
    ai: true
pillar: "Architecture"
tags: ["diagram", "architecture", "rails", "controllers", "models"]
related_docs:
  - path: "/docs/testing/README.md"
  - path: "/docs/diagrams/data-model.md"
  - path: "/docs/architecture/README.md"
---
-->

# Rails Application Architecture

```mermaid
graph TD
  %% Core Components
  Client[Browser/Client] --> Web[Web Interface]
  Web --> Routes[Routes]
  
  %% Controller Layer
  Routes --> AC[ApplicationController]
  AC --> DC[DashboardController]
  AC --> SC[SessionsController]
  AC --> PC[PasswordsController]
  AC --> CC[ChatsController]
  
  %% Model Layer
  DC --> Current
  SC --> Current
  PC --> User
  CC --> Chat
  Current --> User
  Current --> Session
  
  %% Authentication Flow
  SC --> Auth[Authentication]
  Auth --> Session
  Auth --> User
  
  %% View Layer
  DC --> DV[Dashboard Views]
  SC --> SV[Session Views]
  PC --> PV[Password Views]
  CC --> CV[Chat Views]
  
  %% Mailer
  PC --> PM[Password Mailer]
  
  %% Database
  User --> DB[(Database)]
  Chat --> DB
  Session --> DB
  
  %% Styling
  style Client fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#000
  style Routes fill:#e1f5fe,stroke:#333,stroke-width:1px,color:#000
  style AC fill:#bbdefb,stroke:#333,stroke-width:1px,color:#000
  style Current fill:#c8e6c9,stroke:#333,stroke-width:1px,color:#000
  style User fill:#c8e6c9,stroke:#333,stroke-width:1px,color:#000
  style Chat fill:#c8e6c9,stroke:#333,stroke-width:1px,color:#000 
  style Session fill:#c8e6c9,stroke:#333,stroke-width:1px,color:#000
  style Auth fill:#ffe0b2,stroke:#333,stroke-width:1px,color:#000 
  style DB fill:#d1c4e9,stroke:#333,stroke-width:1px,color:#000
```

## Related Resources

- **Code**:
  - [ApplicationController](/app/controllers/application_controller.rb)
  - [DashboardController](/app/controllers/dashboard_controller.rb)
  - [SessionsController](/app/controllers/sessions_controller.rb)
  - [PasswordsController](/app/controllers/passwords_controller.rb)
  - [ChatsController](/app/controllers/chats_controller.rb)
- **Guidelines**:
  - [Diagrams README](/docs/diagrams/README.md)
  - [Architecture README](/docs/architecture/README.md)
- **External**:
  - [Mermaid Documentation](https://mermaid-js.github.io/mermaid/)
  
---

Let's **Visualize** Beautifully! 🧡