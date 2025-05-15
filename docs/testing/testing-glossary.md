---
title: "Testing Glossary"
description: "Definitions for testing-related terms used in the project documentation"
updated: "2025-05-15 10:26:00"
status: "Done 🤎"
contributors:
  - username: aindy
    ai: false
  - username: xai-grok-3
    ai: true
  - username: cursor-anthropic-claude-3-7-sonnet
    ai: true
pillar: "Testing"
tags: ["testing", "glossary", "documentation", "terminology", "reference"]
related_docs:
  - path: "/docs/testing/README.md"
  - path: "/docs/testing/system-testing-guidelines.md"
  - path: "/docs/testing/controller-testing-guidelines.md"
  - path: "/docs/testing/model-testing-guidelines.md"
---

# Testing Glossary

This document provides definitions for all testing-related terms used in the documentation, ensuring consistent terminology.


## Table of Contents

- [Testing Glossary](#testing-glossary)
  - [Table of Contents](#table-of-contents)
  - [A](#a)
  - [B](#b)
  - [C](#c)
  - [D](#d)
  - [E](#e)
  - [F](#f)
  - [H](#h)
  - [I](#i)
  - [J](#j)
  - [M](#m)
  - [P](#p)
  - [R](#r)
  - [S](#s)
  - [T](#t)
  - [U](#u)
  - [V](#v)
  - [W](#w)
  - [Related Resources](#related-resources)


## A

- **Assertion**: A statement that verifies an expected outcome, typically using methods starting with `assert_`.
- **ActiveRecord**: Rails' ORM framework for mapping database records to Ruby objects.
- **ActionMailer**: Rails framework for sending emails that can be tested with mailer tests.


## B

- **Browser testing**: Testing that simulates user interactions in a web browser (see System Tests).


## C

- **Capybara**: A browser automation framework used in system tests to simulate user behavior.
- **Controller**: A Rails component that processes web requests and responds with views or redirects.
- **CI/CD**: Continuous Integration and Continuous Deployment, the automated pipeline for running tests.


## D

- **Database cleaner**: Mechanism for ensuring test data is reset between test runs.
- **DOM**: Document Object Model, the browser's representation of HTML/XML documents.


## E

- **ESLint**: A tool for enforcing JavaScript code quality, not used in this project. We use `bin/importmap audit` for JavaScript dependency checks.


## F

- **Factory**: A method for creating test data dynamically, typically using FactoryBot. See `/docs/testing/database-strategy-guidelines.md` for details.
- **Fixture**: Static test data defined in YAML files.
- **Flaky test**: A test that sometimes passes and sometimes fails with the same code.


## H

- **Headless browser**: A browser without a visible UI, used in CI for running system tests.
- **Helper**: Reusable code to simplify tests or views.


## I

- **Integration test**: Tests that verify multiple parts of the application work together correctly.


## J

- **JavaScript test**: Tests for JavaScript code, typically using Stimulus controllers in this project.


## M

- **Minitest**: The testing framework used by default in Rails.
- **Mock**: An object that mimics behavior of a real object for testing purposes.
- **Model**: A Rails component representing database tables and business logic.


## P

- **Parallel testing**: Running tests simultaneously across multiple processes (not currently implemented, but a future consideration for CI/CD).


## R

- **Rails**: The web framework this application is built on.
- **RSpec**: An alternative testing framework not used in this project.
- **Rubocop**: A Ruby code quality enforcement tool.


## S

- **Stub**: A method replacement used to control test behavior.
- **System test**: High-level tests that verify application behavior through browser automation. See `/docs/testing/system/system-testing-guidelines.md` for details.
- **Stimulus**: A JavaScript framework for creating interactive UI components.


## T

- **Test helper**: Code that assists in setting up test conditions.
- **Transaction**: Database mechanism used to roll back changes after each test.
- **Test-driven development (TDD)**: Writing tests before implementing features.


## U

- **Unit test**: Low-level tests focused on individual components (like models).


## V

- **Validation**: Rules that ensure model data meets expected criteria.


## W

- **WCAG**: Web Content Accessibility Guidelines, standards for making web content accessible. See [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/) for the official standards.


## Related Resources
- **Guidelines**
  - [Testing Overview](/docs/testing/README.md)
  - [Controller Testing](/docs/testing/controller-testing-guidelines.md)
  - [Integration Testing](/docs/testing/integration-testing-guidelines.md)
  - [Model Testing](/docs/testing/model-testing-guidelines.md)
  - [System Testing](/docs/testing/system-testing-guidelines.md)
  - [Architecture Overview](/docs/architecture/README.md)
- **External**
  - [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
  - [Minitest Documentation](https://github.com/minitest/minitest)
  - [Capybara Documentation](https://github.com/teamcapybara/capybara)
  - [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

Let's **Talk** Tests Beautifully! ❤️
