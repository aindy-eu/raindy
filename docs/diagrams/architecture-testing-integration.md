---
title: "Architecture-Testing Integration"
description: "Mermaid diagram illustrating how architectural components are tested at different levels"
updated: "2025-05-15 10:25:00"
status: "Done 🤎"
contributors:
  - username: cursor-anthropic-claude-3-7-sonnet
    ai: true
pillar: "Architecture"
tags: ["diagram", "architecture", "testing", "integration", "rails", "hotwire", "stimulus"]
related_docs:
  - path: "/docs/testing/README.md"
  - path: "/docs/architecture/README.md"
  - path: "/docs/diagrams/testing-pyramid.md"
  - path: "/docs/architecture/technical-overview.md"
---

# Architecture-Testing Integration

```mermaid
flowchart TD
    classDef modelNode fill:#ccccff,stroke:#6666ff,color:black
    classDef viewNode fill:#ffddcc,stroke:#ff9966,color:black
    classDef controllerNode fill:#ccffcc,stroke:#66cc66,color:black
    classDef stimulusNode fill:#ffccff,stroke:#ff66ff,color:black
    classDef turboNode fill:#ffddaa,stroke:#ffaa44,color:black
    classDef testNode fill:#eeeeff,stroke:#9999ff,color:black,stroke-dasharray: 5 5
    
    subgraph "Architecture Components"
        User(("User"))
        
        subgraph "Frontend"
            Views["Views<br/>ERB Templates"]:::viewNode
            Turbo["Turbo<br/>Frames & Streams"]:::turboNode
            Stimulus["Stimulus<br/>Controllers"]:::stimulusNode
        end
        
        subgraph "Backend"
            Controllers["Controllers<br/>Actions & Responses"]:::controllerNode
            Models["Models<br/>Business Logic"]:::modelNode
        end
        
        User -->|interacts| Views
        Views -->|contains| Turbo
        Views -->|data-controller| Stimulus
        Stimulus -->|fetch/submit| Controllers
        Turbo -->|request| Controllers
        Controllers -->|render| Turbo
        Controllers -->|use| Models
        Models -->|return data| Controllers
    end
    
    subgraph "Testing Integration"
        SystemTests["System Tests<br/>(Capybara)"]:::testNode
        IntegrationTests["Integration Tests"]:::testNode
        ControllerTests["Controller Tests"]:::testNode
        ModelTests["Model Tests"]:::testNode
        StimulusTests["Stimulus Tests"]:::testNode
        ViewTests["View Tests"]:::testNode
        
        SystemTests -.->|tests complete UI flow| User
        SystemTests -.->|tests DOM interactions| Views
        SystemTests -.->|tests Turbo updates| Turbo
        SystemTests -.->|tests Stimulus behavior| Stimulus
        
        IntegrationTests -.->|tests multi-step flows| Controllers
        
        ControllerTests -.->|tests single endpoints| Controllers
        ControllerTests -.->|tests Turbo Stream responses| Turbo
        
        ModelTests -.->|tests business logic| Models
        
        StimulusTests -.->|tests JS behavior| Stimulus
        
        ViewTests -.->|tests rendered HTML| Views
    end
```

This diagram illustrates how our architectural components integrate with our testing strategy:

1. **Architecture Components**:
   - **Models**: Core business logic, validations, and data relationships
   - **Controllers**: Handle HTTP requests, process params, and render responses
   - **Views**: ERB templates that define UI structure
   - **Turbo**: Frames and Streams for partial page updates
   - **Stimulus**: JavaScript controllers for interactive behavior

2. **Testing Integration**:
   - **Model Tests**: Directly test business logic in isolation
   - **Controller Tests**: Verify HTTP endpoints and Turbo Stream responses
   - **Integration Tests**: Test multi-step flows across controllers
   - **System Tests**: End-to-end tests of complete user workflows
   - **Stimulus Tests**: Verify JavaScript component behavior
   - **View Tests**: Check correct HTML rendering

Each component is designed with testability in mind:
- **Controllers** use RESTful patterns that map cleanly to controller tests
- **Stimulus controllers** follow consistent patterns that can be tested in isolation
- **Turbo Streams** use predictable DOM IDs that system tests can reliably target
- **Models** separate concerns (validations, associations) for focused testing

This architecture enables our [Testing Pyramid](/docs/diagrams/testing-pyramid.md) approach, with more tests at lower levels (models, controllers) and fewer, more comprehensive tests at higher levels (system). 


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