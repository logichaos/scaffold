<!-- v1.2.1 | amended 2026-03-23 -->

# .NET Scaffold Constitution

## Core Principles

### I. Domain-Driven Design

**Non-negotiable rules**:

- Anemic domain models are PROHIBITED. Behavior and invariants MUST live inside domain objects, not in application services.
- Aggregates MUST enforce their own consistency boundaries. External code MUST NOT bypass aggregate roots to mutate internal state.
- Value Objects MUST be immutable and compared by value, never by identity.
- Domain Events MUST be raised by aggregates when state changes that other parts of the system care about.
- Ubiquitous language MUST be consistent across code, specs, and conversation—no synonyms for the same domain concept.

### II. Clean Architecture

**Non-negotiable rules**:

- The **Domain** layer MUST contain only domain entities, value objects, aggregates, domain events, and domain service interfaces. No framework references.
- The **Application** layer MUST contain use case handlers, application service interfaces, DTOs, and repository/port interfaces. No infrastructure code.
- The **Infrastructure** layer implements ports (repositories, external services, messaging). It MUST NOT leak implementation details into Application or Domain.
- The **Presentation** layer (API, CLI, UI) MUST only depend on Application, never directly on Domain or Infrastructure.
- Dependency Inversion: application and domain layers define interfaces; outer layers implement them.

### III. Vertical Slice Architecture

**Non-negotiable rules**:

- Each slice corresponds to a single use case (e.g., `CreateOrder`, `GetOrderById`). Slices MUST NOT share handlers.
- Slices live under a feature folder (e.g., `Features/Orders/CreateOrder/`). The folder is the unit of delivery—adding a feature means adding a folder.
- Cross-slice sharing is limited to domain objects and infrastructure ports. Shared application-layer types MUST be justified and kept minimal.
- CQRS MUST be applied: Commands mutate state; Queries return data. They MUST NOT be combined in a single handler.
- Mediator (martinothamar/Mediator) MUST be used to dispatch commands and queries, keeping slices decoupled from presentation.

### IV. Test-First Development (NON-NEGOTIABLE)

**Non-negotiable rules**:

- **Red**: Write a test that describes the desired behavior. The test MUST fail before any production code is written. A test that passes before implementation is invalid.
- **Green**: Write the minimum production code required to make the test pass. No gold-plating.
- **Refactor**: Clean up duplication and structure without changing behavior. Tests MUST remain green throughout refactoring.
- Unit tests MUST cover domain objects (aggregates, value objects, domain services) in isolation—no framework, no database.
- Integration tests MUST cover application slices end-to-end (handler → repository → database). Use a real database or in-memory equivalent per slice.
- Tests MUST be named using the pattern: `[Method]_[Scenario]_[ExpectedResult]` or equivalent BDD style (`Given_When_Then`).
- No PR may be merged with failing tests or with production code that has no corresponding test.

### V. Simplicity & YAGNI

**Non-negotiable rules**:

- Abstractions are PROHIBITED unless immediately required by two or more concrete use cases, or mandated by a higher principle (e.g., Clean Architecture port interfaces).
- Generic utilities and base classes MUST NOT be created for a single use case.
- Premature optimization is PROHIBITED. Profile before optimizing.
- Complexity introduced to satisfy DDD or architecture principles MUST be documented in the Complexity Tracking section of plan.md.

## .NET Technology Stack

- **Language**: C# (latest stable LTS version)
- **Test Framework**: TUnit with FluentAssertions; NSubstitute for mocking
- **Mediator**: Mediator (martinothamar/Mediator) — source-generated, zero-allocation command/query dispatch
- **Validation**: FluentValidation (Mediator pipeline behavior)
- **ORM / Persistence**: Entity Framework Core (Infrastructure layer only)
- **Architecture compliance**: ArchUnitNET or NetArchTest — dependency rule violations MUST fail the build
- **Project structure**:

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

## Development Workflow

- **Branch naming**: `###-feature-name` (e.g., `001-create-order`)
- **TDD gate**: No task is complete until tests exist, were observed Red, made Green, and Refactored
- **PR requirements**: all tests green; architecture tests green; no new code without test coverage; Complexity Tracking filled if any principle deviation is justified
- **Commit discipline**: commit after each Red→Green→Refactor cycle; small frequent commits preferred
- **Feature delivery**: each vertical slice MUST be shippable in isolation; `make coverage ≥ 90%` required before merge

## Governance

This constitution supersedes all other development practices in this repository. When a practice conflicts, the constitution wins or an amendment must be filed.

**Amendment procedure**:

1. Open a discussion (PR, issue, or team meeting) describing the proposed change and its rationale.
2. Increment the version per semver rules below.
3. Update `LAST_AMENDED_DATE` to the merge date.
4. Run the consistency propagation checklist: verify plan-template.md, spec-template.md, tasks-template.md, and command files are still aligned.

**Version policy**:

- **MAJOR**: Removal or redefinition of a core principle (backward-incompatible governance change).
- **MINOR**: New principle or section added; material expansion of existing guidance.
- **PATCH**: Clarification, wording refinement, typo fix.

**Compliance review**: Every PR MUST include confirmation that the change complies with all five core principles. The plan.md Complexity Tracking table MUST be filled for any justified deviation.

**Version**: 1.2.1 | **Ratified**: 2026-03-23 | **Last Amended**: 2026-03-23
