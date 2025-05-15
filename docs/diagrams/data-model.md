---
title: "Data Model"
description: "Mermaid class diagram illustrating the application's data model and relationships"
updated: "2025-05-15 10:26:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: cursor-anthropic-claude-3-7-sonnet
    ai: true
pillar: "Architecture"
tags: ["diagram", "data-model", "database", "models", "relationships"]
related_docs:
  - path: "/docs/testing/README.md"
  - path: "/docs/diagrams/app-architecture.md"
  - path: "/docs/architecture/README.md"
---

# Data Model

```mermaid
classDiagram
  class User {
    -id: string (UUID)
    -email_address: string
    -password_digest: string
    -created_at: datetime
    -updated_at: datetime
    +has_many chats
    +has_many sessions
  }
  class Session {
    -id: string (UUID)
    -user_id: string
    -ip_address: string
    -user_agent: string
    -created_at: datetime
    -updated_at: datetime
    +belongs_to user
  }
  class Chat {
    -id: string (UUID)
    -user_id: string
    -name: string
    -created_at: datetime
    -updated_at: datetime
    +belongs_to user
  }
  class Current {
    -session: Session
    +delegate user
  }
  User --> Session : has_many
  User --> Chat : has_many
  Session --> User : belongs_to
  Chat --> User : belongs_to
  Current --> Session : references
```

## Related Resources

- **Code**:
  - [Chat Model](/app/models/chat.rb)
  - [Session Model](/app/models/session.rb)
  - [User Model](/app/models/user.rb)
- **Guidelines**:
  - [Diagrams README](/docs/diagrams/README.md)
  - [Architecture README](/docs/architecture/README.md)
- **External**:
  - [Mermaid Documentation](https://mermaid-js.github.io/mermaid/)

---

Let's **Visualize** Beautifully! 🧡
