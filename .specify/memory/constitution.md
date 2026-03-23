<!--
SYNC IMPACT REPORT
==================
Version change: 1.0.0 → 1.1.0
Modified principles:
  - .NET Technology Stack: xUnit → TUnit; MediatR → Mediator (martinothamar/Mediator);
    Mediator pipeline behavior note updated to Mediator source-generated equivalent
Added sections:
  - I. Domain-Driven Design
  - II. Clean Architecture
  - III. Vertical Slice Architecture
  - IV. Test-First Development (NON-NEGOTIABLE)
  - V. Simplicity & YAGNI
  - .NET Technology Stack
  - Development Workflow
  - Governance
Removed sections: N/A (template placeholders replaced)
Templates requiring updates:
  - ✅ .specify/memory/constitution.md — written now
  - ⚠ .specify/templates/plan-template.md — Constitution Check section references
    generic gates; update when planning real features to reflect DDD/CA/VSA rules
  - ⚠ .specify/templates/tasks-template.md — path conventions use generic src/
    layout; update to reflect .NET project structure (src/, tests/) when needed
  - ⚠ .specify/templates/spec-template.md — no changes required at this time
Deferred TODOs:
  - TODO(PROJECT_NAME): Confirmed as ".NET Scaffold" from repo path; update if
    project is renamed.
  - TODO(RATIFICATION_DATE): Set to today (2026-03-23); update to actual team
    adoption date if this project has multiple contributors.
-->

# .NET Scaffold Constitution

## Core Principles

### I. Domain-Driven Design

The domain model is the heart of the system. All code MUST reflect the ubiquitous
language agreed upon with stakeholders. Domain concepts—Aggregates, Entities, Value
Objects, Domain Events, and Domain Services—MUST be explicit, named types in the
domain layer.

**Non-negotiable rules**:

- Anemic domain models are PROHIBITED. Behavior and invariants MUST live inside
  domain objects, not in application services.
- Aggregates MUST enforce their own consistency boundaries. External code MUST NOT
  bypass aggregate roots to mutate internal state.
- Value Objects MUST be immutable and compared by value, never by identity.
- Domain Events MUST be raised by aggregates when state changes that other parts of
  the system care about.
- Ubiquitous language MUST be consistent across code, specs, and conversation—no
  synonyms for the same domain concept.

**Rationale**: DDD ensures the codebase remains aligned with business intent and that
domain complexity is captured where it belongs—inside the domain—not scattered across
services and controllers.

### II. Clean Architecture

Dependencies MUST flow inward: Infrastructure and Presentation depend on Application,
Application depends on Domain. Domain MUST have zero dependencies on any outer layer
or third-party framework.

**Non-negotiable rules**:

- The **Domain** layer MUST contain only domain entities, value objects, aggregates,
  domain events, and domain service interfaces. No framework references.
- The **Application** layer MUST contain use case handlers, application service
  interfaces, DTOs, and repository/port interfaces. No infrastructure code.
- The **Infrastructure** layer implements ports (repositories, external services,
  messaging). It MUST NOT leak implementation details into Application or Domain.
- The **Presentation** layer (API, CLI, UI) MUST only depend on Application, never
  directly on Domain or Infrastructure.
- Dependency Inversion: application and domain layers define interfaces; outer layers
  implement them.

**Rationale**: Clean Architecture protects the domain from framework churn, makes the
system independently testable at each layer, and enforces a clear separation of
concerns.

### III. Vertical Slice Architecture

Features MUST be organized as self-contained vertical slices rather than horizontal
layers. Each slice owns everything required to fulfill one use case: command/query,
handler, validator, response DTO, and any slice-local models.

**Non-negotiable rules**:

- Each slice corresponds to a single use case (e.g., `CreateOrder`, `GetOrderById`).
  Slices MUST NOT share handlers.
- Slices live under a feature folder (e.g., `Features/Orders/CreateOrder/`). The
  folder is the unit of delivery—adding a feature means adding a folder.
- Cross-slice sharing is limited to domain objects and infrastructure ports. Shared
  application-layer types (e.g., base handlers, generic responses) MUST be justified
  and kept minimal.
- CQRS MUST be applied: Commands mutate state; Queries return data. They MUST NOT be
  combined in a single handler.
- Mediator (martinothamar/Mediator) MUST be used to dispatch commands and queries,
  keeping slices decoupled from presentation.

**Rationale**: Vertical slices minimize merge conflicts, enable parallel development,
and keep each use case independently deployable and testable. Combined with Clean
Architecture it gives clear ownership without sacrificing domain integrity.

### IV. Test-First Development (NON-NEGOTIABLE)

All production code MUST be preceded by a failing test. The Red→Green→Refactor cycle
is STRICTLY enforced and is not optional under any circumstance.

**Non-negotiable rules**:

- **Red**: Write a test that describes the desired behavior. The test MUST fail before
  any production code is written. A test that passes before implementation is invalid.
- **Green**: Write the minimum production code required to make the test pass. No
  gold-plating.
- **Refactor**: Clean up duplication and structure without changing behavior. Tests
  MUST remain green throughout refactoring.
- Unit tests MUST cover domain objects (aggregates, value objects, domain services)
  in isolation—no framework, no database.
- Integration tests MUST cover application slices end-to-end (handler → repository
  → database). Use a real database or in-memory equivalent per slice.
- Tests MUST be named using the pattern: `[Method]_[Scenario]_[ExpectedResult]` or
  equivalent BDD style (`Given_When_Then`).
- No PR may be merged with failing tests or with production code that has no
  corresponding test.

**Rationale**: TDD is the primary design and quality mechanism. It prevents over-
engineering, provides a safety net for refactoring, and documents intended behavior
in executable form.

### V. Simplicity & YAGNI

The simplest solution that satisfies the current requirement MUST be preferred. Code
MUST NOT be written for hypothetical future needs.

**Non-negotiable rules**:

- Abstractions are PROHIBITED unless they are immediately required by two or more
  concrete use cases, or mandated by a higher principle (e.g., Clean Architecture
  port interfaces).
- Generic utilities and base classes MUST NOT be created for a single use case.
- Premature optimization is PROHIBITED. Profile before optimizing.
- Complexity introduced to satisfy DDD or architecture principles MUST be documented
  in the Complexity Tracking section of plan.md.

**Rationale**: Unnecessary complexity is the leading cause of maintenance burden and
bugs. YAGNI keeps the codebase lean and understandable.

## .NET Technology Stack

This project targets the .NET ecosystem. The following constraints apply to all
features unless explicitly overridden in a feature's plan.md.

- **Language**: C# (latest stable LTS version)
- **Test Framework**: TUnit with FluentAssertions; NSubstitute for mocking
- **Mediator**: Mediator (martinothamar/Mediator) — source-generated, zero-allocation
  command/query dispatch (Vertical Slice)
- **Validation**: FluentValidation (Mediator pipeline behavior)
- **ORM / Persistence**: Entity Framework Core (Infrastructure layer only)
- **Project structure per slice**:

  ```
  src/
  ├── Domain/          # Aggregates, entities, value objects, domain events
  ├── Application/     # Use case handlers, ports, DTOs (organized by feature)
  │   └── Features/
  │       └── [FeatureName]/
  │           ├── [Command|Query].cs
  │           ├── [Command|Query]Handler.cs
  │           └── [Command|Query]Validator.cs
  └── Infrastructure/  # EF Core, external integrations, repository implementations
  tests/
  ├── Domain.Tests/    # Unit tests for domain objects
  ├── Application.Tests/ # Integration tests per slice
  └── Architecture.Tests/ # ArchUnitNET dependency direction tests
  ```

- Architecture compliance MUST be validated by automated tests using ArchUnitNET or
  NetArchTest. Dependency rule violations MUST fail the build.

## Development Workflow

- **Branch naming**: `###-feature-name` (e.g., `001-create-order`)
- **TDD gate**: No implementation task may be marked complete until its tests exist,
  were observed to fail (Red), were made to pass (Green), and code was cleaned up
  (Refactor).
- **PR requirements**:
  - All tests green
  - Architecture tests green (no dependency rule violations)
  - No new code without corresponding test coverage
  - Complexity Tracking filled in plan.md if any principle violation is justified
- **Commit discipline**: Commit after each Red→Green→Refactor cycle. Small, frequent
  commits are preferred over large squash commits.
- **Feature delivery**: Each vertical slice is independently releasable. Slices MUST
  be shippable in isolation without waiting for other slices in the same feature.

## Governance

This constitution supersedes all other development practices and conventions in this
repository. When a practice conflicts with the constitution, the constitution wins or
an amendment must be filed.

**Amendment procedure**:

1. Open a discussion (PR, issue, or team meeting) describing the proposed change and
   its rationale.
2. Increment the version according to semver rules (see version policy below).
3. Update `LAST_AMENDED_DATE` to the date the amendment is merged.
4. Run the consistency propagation checklist: verify plan-template.md, spec-template.md,
   tasks-template.md, and command files are still aligned.

**Version policy**:

- **MAJOR**: Removal or redefinition of a core principle (backward-incompatible
  governance change).
- **MINOR**: New principle or section added; material expansion of existing guidance.
- **PATCH**: Clarification, wording refinement, typo fix.

**Compliance review**: Every PR review MUST include a verbal or checklist confirmation
that the change complies with all five core principles. The plan.md Complexity Tracking
table MUST be filled for any justified deviation.

**Version**: 1.1.0 | **Ratified**: 2026-03-23 | **Last Amended**: 2026-03-23
