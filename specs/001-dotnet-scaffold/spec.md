# Feature Specification: .NET Project Scaffold

**Feature Branch**: `001-dotnet-scaffold`
**Created**: 2026-03-23
**Status**: Draft
**Input**: User description: "build the scaffold for a .net application that I can use to onboard new projects. It should supply ready build scripts/makefiles, code projects, test projects, etc"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Bootstrap a new .NET project from the scaffold (Priority: P1)

A developer clones this repository (or copies it as a template) and runs a single command to set up a brand-new .NET solution that is immediately buildable, testable, and ready for feature work. The scaffold produces a complete solution directory with all required projects, folder conventions, and build tooling wired together.

**Why this priority**: Without a working, runnable scaffold the remaining stories have nothing to build on. This story delivers the core value of the feature.

**Independent Test**: Can be fully tested by running the bootstrap command in an empty directory and verifying the resulting solution compiles and all test projects pass with `make build && make test`.

**Acceptance Scenarios**:

1. **Given** an empty working directory, **When** the developer runs the scaffold bootstrap command, **Then** a complete .NET solution is created with Domain, Application, Infrastructure, and Presentation projects plus corresponding test projects.
2. **Given** a freshly scaffolded solution, **When** the developer runs the build target, **Then** all projects compile without errors or warnings.
3. **Given** a freshly scaffolded solution, **When** the developer runs the test target, **Then** all test projects execute and pass (zero failures, zero skipped).
4. **Given** a freshly scaffolded solution, **When** the developer opens it in an IDE, **Then** the solution file correctly references all projects.

---

### User Story 2 - Run quality gates via Makefile targets (Priority: P2)

A developer can run standardised Makefile targets (`make build`, `make test`, `make coverage`, `make lint`, `make clean`) without needing to know the underlying CLI invocations. Every target works out of the box on the scaffolded solution.

**Why this priority**: Consistent build tooling is required by the constitution and enables CI pipelines and team onboarding without tribal knowledge.

**Independent Test**: Can be fully tested by executing each Makefile target against the scaffolded solution and verifying the expected output and exit codes.

**Acceptance Scenarios**:

1. **Given** a scaffolded solution, **When** `make coverage` is run, **Then** a coverage report is produced and the build fails if coverage falls below 90%.
2. **Given** a scaffolded solution, **When** `make lint` is run, **Then** static analysis runs and reports any rule violations.
3. **Given** a scaffolded solution, **When** `make clean` is run, **Then** all build artefacts (`bin/`, `obj/`, coverage reports) are removed.
4. **Given** a CI environment with the required SDK installed, **When** each Makefile target is executed, **Then** the target succeeds without requiring manual configuration steps.

---

### User Story 3 - Enforce architecture compliance automatically (Priority: P3)

Architecture tests in the `Architecture.Tests` project validate the Clean Architecture dependency rules. Any violation causes the test suite (and therefore `make test`) to fail, making compliance enforcement automatic rather than relying on code review alone.

**Why this priority**: Architecture compliance is a constitution requirement and must be self-reinforcing. However, it builds on the foundational scaffold (P1) and build tooling (P2).

**Independent Test**: Can be tested by deliberately introducing a Domain → Infrastructure dependency and confirming that `make test` fails with a descriptive error.

**Acceptance Scenarios**:

1. **Given** a scaffolded solution with correct dependencies, **When** `make test` is run, **Then** architecture tests pass.
2. **Given** a scaffolded solution where Infrastructure is referenced from Domain, **When** `make test` is run, **Then** architecture tests fail with a message identifying the violating reference.
3. **Given** a scaffolded solution where Application is referenced from Domain, **When** `make test` is run, **Then** architecture tests fail.

---

### Edge Cases

- What happens when the target directory already contains a solution file? The scaffold must detect the conflict and exit with a clear error rather than overwriting existing work.
- What happens when the required SDK version is not installed? The bootstrap script must check prerequisites and emit a human-readable error before attempting to create any files.
- What happens when `make coverage` runs but no tests exist yet? The tool must handle an empty test suite gracefully (0% coverage below the 90% threshold should fail with a clear message, not a cryptic crash).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The scaffold MUST produce a solution file referencing all generated projects.
- **FR-002**: The scaffold MUST generate the following production projects: `Domain`, `Application`, `Infrastructure`; and test projects: `Domain.Tests`, `Application.Tests`, `Architecture.Tests`.
- **FR-003**: Each generated project MUST be placed in the correct directory (`src/` for production projects, `tests/` for test projects) matching the constitution's project structure.
- **FR-004**: The scaffold MUST generate a `Makefile` with at minimum the targets: `build`, `test`, `coverage`, `lint`, `clean`.
- **FR-005**: The `make coverage` target MUST fail the build when test coverage falls below 90%.
- **FR-006**: The `Architecture.Tests` project MUST contain pre-written tests that enforce the Clean Architecture dependency rules: Domain has no outward dependencies; Application does not reference Infrastructure; Presentation does not reference Domain directly.
- **FR-007**: The scaffold MUST include configuration files to enforce consistent code style and compiler settings across all projects.
- **FR-008**: The `Domain` project MUST NOT reference any third-party framework packages by default.
- **FR-009**: The scaffold MUST include a `README.md` at the solution root describing how to use the Makefile targets and the project structure.
- **FR-010**: The scaffold bootstrap MUST be idempotent: running it twice on the same directory MUST be safe (detect existing scaffold and skip or prompt for confirmation before overwriting).

### Key Entities

- **Solution**: The top-level grouping file referencing all projects; has a name derived from the project being onboarded.
- **Project**: An individual unit (Domain, Application, Infrastructure, Domain.Tests, Application.Tests, Architecture.Tests); each has a specific responsibility and dependency budget.
- **Makefile Target**: A named recipe (`build`, `test`, `coverage`, `lint`, `clean`) that encapsulates a repeatable developer action.
- **Architecture Rule**: A test assertion that enforces a dependency-direction constraint between layers.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A developer with a clean SDK installation can go from zero to a fully compiling, test-passing solution in under 5 minutes using only the scaffold and its documented commands.
- **SC-002**: All Makefile targets complete successfully on the scaffolded solution without any manual configuration steps beyond installing the required SDK.
- **SC-003**: The `make coverage` gate correctly blocks the build when coverage is below 90%, verified by an automated acceptance test.
- **SC-004**: Architecture tests catch 100% of deliberate layer-boundary violations introduced during acceptance testing.
- **SC-005**: A new team member can understand the project structure and run their first successful build within 10 minutes using only the generated `README.md`.

## Assumptions

- The target developer environment has the .NET SDK (latest stable LTS) installed; the scaffold does not provision the SDK itself.
- The scaffold produces a ready-to-use starting point and does not generate domain-specific business logic.
- "Makefile" means a GNU `Makefile` compatible with Linux/macOS; Windows support via WSL is the minimum bar.
- Package references (TUnit, FluentAssertions, NSubstitute, Mediator, FluentValidation, EF Core, ArchUnitNET) will be pinned to their latest stable versions at scaffold generation time.
- The scaffold is implemented as a shell script rather than a `dotnet new` template; a template-based variant may be a future enhancement.
