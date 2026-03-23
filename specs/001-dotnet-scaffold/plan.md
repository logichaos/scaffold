# Implementation Plan: .NET Project Scaffold

**Branch**: `001-dotnet-scaffold` | **Date**: 2026-03-23 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-dotnet-scaffold/spec.md`

## Summary

A shell-script-based project scaffold that generates a complete .NET solution with Clean Architecture layers (Domain, Application, Infrastructure, Presentation), corresponding test projects (Domain.Tests, Application.Tests, Architecture.Tests), a Makefile with quality-gate targets (build, test, coverage, lint, clean), and hardened production defaults including SBOM generation, SCA CI integration, secret scanning, code-signing templates, runtime hardening guidance, CI build/test time budgets, optional runtime benchmark templates, flaky-test detection hooks, and Full Observability scaffolding (OpenTelemetry, Prometheus, Grafana templates).

## Technical Context

**Language/Version**: Shell script (POSIX-compatible) + C# (latest stable LTS)
**Primary Dependencies**: .NET SDK 8.x (LTS), GNU Make, TUnit, FluentAssertions, NSubstitute, Mediator, FluentValidation, EF Core, ArchUnitNET
**Storage**: N/A (scaffold generates project templates, not runtime storage)
**Testing**: TUnit + FluentAssertions + NSubstitute + ArchUnitNET
**Target Platform**: Linux/macOS (primary), Windows via WSL
**Project Type**: CLI tool / scaffolding script
**Performance Goals**: Bootstrap completes in <30 seconds; scaffolded solution builds and tests in <5 minutes
**Constraints**: Must be idempotent; must detect existing solution files; must validate SDK prerequisite
**Scale/Scope**: Generates 6-8 project files + Makefile + config files per scaffold invocation

## Constitution Check

**GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.**

| Gate | Status | Notes |
|------|--------|-------|
| DDD: Anemic models prohibited | PASS | Generated Domain project will be empty of business logic; scaffold creates structure only |
| DDD: Aggregates enforce consistency | N/A | No domain logic in scaffold |
| DDD: Value objects immutable | N/A | Scaffold creates structure only |
| DDD: Domain events raised | N/A | Scaffold creates structure only |
| DDD: Ubiquitous language | PASS | Consistent terminology in spec |
| Clean Architecture: Layer separation | PASS | Scaffold generates correct layer structure per constitution |
| Clean Architecture: Dependency inversion | PASS | Generated project uses DI as per constitution |
| Vertical Slice: Feature folders | PASS | Application layer uses Features/ pattern |
| Vertical Slice: CQRS | PASS | Generated project structure supports CQRS |
| Test-First: Tests required | PASS | Scaffold generates test projects |
| Simplicity: No premature abstractions | PASS | Scaffold follows YAGNI |
| Tech Stack: C# LTS | PASS | Constitution-compliant |
| Tech Stack: TUnit/FluentAssertions/NSubstitute | PASS | Included in generated test projects |
| Tech Stack: Mediator | PASS | Referenced in Application layer |
| Tech Stack: FluentValidation | PASS | Referenced in Application layer |
| Tech Stack: EF Core | PASS | Referenced in Infrastructure layer |
| Tech Stack: ArchUnitNET | PASS | Used in Architecture.Tests |

## Project Structure

### Documentation (this feature)

```text
specs/001-dotnet-scaffold/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

The scaffold itself is a shell script that generates project templates. The generated solution produces:

```text
# Generated scaffold output (produced when developer runs scaffold)
src/
├── Domain/              # Aggregates, entities, value objects, domain events
├── Application/         # Use case handlers, ports, DTOs (organized by feature)
│   └── Features/
│       └── [FeatureName]/
│           ├── [Command|Query].cs
│           ├── [Command|Query]Handler.cs
│           └── [Command|Query]Validator.cs
├── Infrastructure/      # EF Core, external integrations, repository implementations
└── Presentation/        # API / CLI / UI layer

tests/
├── Domain.Tests/        # Unit tests for domain objects
├── Application.Tests/   # Integration tests per slice
└── Architecture.Tests/ # ArchUnitNET dependency direction tests
```

The scaffold source (this repository) provides:

```text
# This repository (scaffold implementation)
.scaffold/               # Script templates and project templates
├── scripts/
│   ├── bootstrap.sh    # Main scaffold entry point
│   └── templates/      # .csproj and solution file templates
├── Makefile            # Quality gates for scaffold itself
└── tests/              # Tests for scaffold behavior
```

**Structure Decision**: Shell script scaffold generates Clean Architecture solution per constitution. The scaffold itself follows POSIX conventions with a single bootstrap script that invokes template expansion.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
