<!--
---
title: "Model Guidelines"
description: "Conventions for writing and organizing ActiveRecord models in this Rails application"
updated: "2025-05-15 10:18:00"
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
tags: ["rails", "models", "architecture"]
related_docs:
  - path: "/app/models/chat.rb"
  - path: "/app/models/user.rb"
  - path: "/app/models/concerns/uuid_concern.rb"
  - path: "/app/models/concerns/sanitization_concern.rb"
  - path: "/app/models/concerns/strict_validation_concern.rb"
  - path: "/docs/architecture/README.md"
  - path: "/docs/architecture/technical-overview.md"
  - path: "/docs/testing/model-testing-guidelines.md"
  - path: "/docs/ai/guidelines/ai-reviewer-guidelines.md"
---
-->

# Model Guidelines

This document outlines conventions for writing and organizing ActiveRecord models in our Rails application. The goal is to ensure models are readable, maintainable, and secure.

## Table of Contents
- [Model Guidelines](#model-guidelines)
  - [Table of Contents](#table-of-contents)
  - [1. General Principles](#1-general-principles)
  - [2. Recommended Section Order](#2-recommended-section-order)
    - [Example](#example)
  - [3. Use of Concerns](#3-use-of-concerns)
  - [4. Normalization](#4-normalization)
  - [5. Validations](#5-validations)
  - [6. UUIDs Instead of IDs](#6-uuids-instead-of-ids)
  - [7. Current Attributes](#7-current-attributes)
  - [8. Reserved Characters in Fields](#8-reserved-characters-in-fields)
  - [9. Default Scopes](#9-default-scopes)
  - [10. Secure Password](#10-secure-password)
  - [11. Associations](#11-associations)
  - [12. Testing Models](#12-testing-models)
  - [Summary](#summary)
  - [13. Related Resources](#13-related-resources)

## 1. General Principles

- **Encapsulation**: Keep business logic in models when it relates to data or domain rules.
- **Shared Logic**: Use concerns to share reusable code (e.g., UUIDs, sanitization).
- **Explicitness**: Define clear validations and behaviors, avoiding hidden defaults.
- **Readability**: Follow a consistent section order for model code.


## 2. Recommended Section Order

Organize models with the following sections for clarity:

```ruby
# Includes
# Constants
# Attribute Macros
# Normalizers
# Associations
# Enums
# Callbacks
# Validations
# Delegations
# Scopes
# Class Methods
# Instance Methods
```

### Example
```ruby
class Chat < ApplicationRecord
  # Includes
  include UuidConcern
  include StrictValidationConcern
  include SanitizationConcern

  # Constants
  # (Defined in Constants module, e.g., Constants::MAX_CHAT_NAME_LENGTH)

  # Attribute Macros
  # attr_accessor ...

  # Normalizers
  normalizes :name, with: ->(n) { n.strip }

  # Associations
  belongs_to :user

  # Enums
  # enum status: { active: 0, archived: 1 }

  # Callbacks
  sanitize_columns :name, tags: [], attributes: [], strip: true

  # Validations
  validates :name,
    presence: true,
    length: {
      minimum: Constants::MIN_NAME_LENGTH,
      maximum: Constants::MAX_CHAT_NAME_LENGTH,
      allow_blank: true
    }
  strict_validate :name, with: STRICT_REGEX

  # Delegations
  # delegate :email_address, to: :user

  # Scopes
  default_scope { order(created_at: :desc) }
  scope :asc, -> { reorder(created_at: :asc) }

  # Class Methods
  # def self.recent ...

  # Instance Methods
  # def display_name ...
end
```

See `app/models/chat.rb` for the full implementation.


## 3. Use of Concerns

Concerns in `app/models/concerns/` share reusable logic across models:
- `UuidConcern`: Assigns UUIDs as primary keys before creation.
- `SanitizationConcern`: Sanitizes strings, converting characters like `&` to `&amp;` and optionally stripping newlines/tabs.
- `StrictValidationConcern`: Enforces rules to block unsafe characters (e.g., `<`, `"`, `$`).

Create shared callbacks and helper methods into concerns when used across multiple models.

Example:
```ruby
sanitize_columns :name, tags: [], attributes: [], strip: true
```

See `app/models/concerns/sanitization_concern.rb` for details on HTML entity conversion.


## 4. Normalization

Use `normalizes` to standardize attributes before validation:

```ruby
normalizes :email_address, with: ->(e) { e.strip.downcase }
```

This ensures consistent formatting (e.g., lowercase emails) and reduces validation errors. See `app/models/user.rb` for usage.


## 5. Validations

Group validations by attribute and use `I18n` for error messages:

```ruby
validates :email_address,
  presence: true,
  uniqueness: true,
  format: { with: EMAIL_VALIDATION_REGEX, message: I18n.t("errors.messages.invalid_email") }
```

Define regex constants like `EMAIL_VALIDATION_REGEX` in the model, or use `STRICT_REGEX` from the `StrictValidationConcern` for consistency.


## 6. UUIDs Instead of IDs

Use `UuidConcern` to assign UUIDs as primary keys:

```ruby
class User < ApplicationRecord
  include UuidConcern
end
```

This generates a `SecureRandom.uuid` before creation. See `app/models/concerns/uuid_concern.rb`.


## 7. Current Attributes

The `Current` object (`app/models/current.rb`) provides request-local context, such as the current user:

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true
end
```

## 8. Reserved Characters in Fields

Use `StrictValidationConcern` to block unsafe characters defined in `Constants::FORBIDDEN_CHARACTERS`:

```ruby
strict_validate :name, with: STRICT_REGEX
```

`STRICT_REGEX` ensures fields like `name` exclude characters like `<`, `>`, `"`, etc. Combine with `sanitize_columns` to prevent XSS and malformed input. See `app/models/concerns/strict_validation_concern.rb` for details.


## 9. Default Scopes

Use `default_scope` to set a default order for queries:

```ruby
default_scope { order(created_at: :desc) }
```

Provide alternative scopes (e.g., `asc`) to override the default. See `app/models/chat.rb` for usage.


## 10. Secure Password

Use `has_secure_password` for secure password handling:

```ruby
class User < ApplicationRecord
  has_secure_password
end
```

This adds password digestion and authentication methods. See `app/models/user.rb`.


## 11. Associations

Define associations with appropriate options (e.g., `dependent: :destroy`):

```ruby
class User < ApplicationRecord
  has_many :chats, dependent: :destroy
  has_many :sessions, dependent: :destroy
end
```

Use `dependent: :destroy` to clean up related records when the parent is deleted. See `app/models/user.rb`.


## 12. Testing Models

Write tests to verify validations, associations, scopes, and concerns. See `/docs/testing/model-testing-guidelines.md` for details.

## Summary
- Organize models with a consistent section order.
- Use concerns for shared logic (UUIDs, sanitization, validations).
- Normalize attributes for consistency.
- Validate fields with `I18n` messages and `STRICT_REGEX`.
- Use UUIDs, `Current` attributes, default scopes, and `has_secure_password` as needed.
- Define associations with cleanup options.


## 13. Related Resources
- **Code**:
  - [Chat Model](/app/models/chat.rb)
  - [User Model](/app/models/user.rb)
  - [Uuid Concern](/app/models/concerns/uuid_concern.rb)
  - [Sanitization Concern](/app/models/concerns/sanitization_concern.rb)
  - [Strict Validation Concern](/app/models/concerns/strict_validation_concern.rb)
- **Guidelines**:
  - [Architecture Overview](/docs/architecture/README.md)
  - [Technical Overview](/docs/architecture/technical-overview.md)
  - [Model Testing Guidelines](/docs/testing/model-testing-guidelines.md)
  - [Stimulus Guidelines](/docs/architecture/stimulus-guidelines.md)
- **External**:
  - [Rails Model Validations](https://guides.rubyonrails.org/active_record_validations.html)
  - [ActiveSupport::CurrentAttributes](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html)
  - [Active Model Basics](https://guides.rubyonrails.org/active_model_basics.html)
  - [ActiveRecord Callbacks](https://guides.rubyonrails.org/active_record_callbacks.html)
  - [Rails Concerns](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)

---

Let's **Model** Beautifully! 🩵