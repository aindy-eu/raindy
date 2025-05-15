---
title: "Testing Pyramid"
description: "Mermaid pyramid diagram illustrating the different types of tests and their relationships"
updated: "2025-05-15 10:25:00"
status: "Done 🤎"
contributors:
  - username: cursor-anthropic-claude-3-7-sonnet
    ai: true
pillar: "Testing"
tags: ["diagram", "testing", "minitest", "system-tests", "integration-tests", "controller-tests", "model-tests"]
related_docs:
  - path: "/docs/testing/README.md"
  - path: "/docs/testing/system-testing-guidelines.md"
  - path: "/docs/testing/integration-testing-guidelines.md"
  - path: "/docs/testing/controller-testing-guidelines.md"
  - path: "/docs/testing/model-testing-guidelines.md"
---

# Testing Pyramid

```mermaid
graph TD
    classDef system fill:#ffcccb,stroke:#ff6666,color:black
    classDef integration fill:#ffffcc,stroke:#ffcc00,color:black
    classDef controller fill:#ccffcc,stroke:#66cc66,color:black
    classDef model fill:#ccccff,stroke:#6666ff,color:black
    
    subgraph "Testing Pyramid"
        S["System Tests<br/>(UI / Acceptance)<br/>Capybara, Selenium<br/>Slow but Comprehensive"]:::system
        I["Integration Tests<br/>Multi-step Flows<br/>HTTP Requests<br/>Moderate Speed"]:::integration
        C["Controller Tests<br/>Single Endpoints<br/>Turbo Stream<br/>Faster"]:::controller
        M["Model Tests<br/>Business Logic<br/>Validations<br/>Fastest"]:::model
        
        S --> I
        I --> C
        C --> M
    end
        
    subgraph "Test Count/Speed"
        high["High Count<br/>Fast Execution"]
        low["Low Count<br/>Slow Execution"]
        
        low --> high
    end
    
    S -.- low
    M -.- high
```

The testing pyramid visualizes the different types of tests in our application and their relationships:

1. **Model Tests** (Bottom Layer):
   - Fastest execution, highest quantity
   - Test business logic, validations, associations
   - Example: Verify a chat requires a name

2. **Controller Tests**:
   - Test single HTTP endpoints and Turbo Stream responses
   - Example: Verify chat creation returns correct turbo_stream

3. **Integration Tests**:
   - Test multi-step flows across controllers
   - Example: Sign in and create a chat

4. **System Tests** (Top Layer):
   - Slowest execution, lowest quantity
   - Test end-to-end workflows with browser simulation
   - Example: User signs in, opens drawer, creates chat with keyboard

This pyramid follows the testing philosophy described in the [Testing Overview](/docs/testing/README.md), with more tests at lower levels (model, controller) and fewer, more comprehensive tests at higher levels (integration, system). 

## Related Resources

- **Code**:
  - [ApplicationController](/app/controllers/application_controller.rb)
  - [ChatsController](/app/controllers/chats_controller.rb)
  - [Chat Model](/app/models/chat.rb)
  - [User Model](/app/models/user.rb)
- **Guidelines**:
  - [Diagrams README](/docs/diagrams/README.md)
  - [Testing README](/docs/testing/README.md)
- **External**:
  - [Mermaid Documentation](https://mermaid-js.github.io/mermaid/)

---

Let's **Visualize** Beautifully! 🧡