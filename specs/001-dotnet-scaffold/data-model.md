# Data Model: .NET Project Scaffold

## Overview

The scaffold generates a Clean Architecture solution structure. The data model here describes the *template inputs* and *generated outputs*, not runtime domain entities.

## Template Inputs

| Input | Type | Description | Validation |
|-------|------|-------------|------------|
| `SOLUTION_NAME` | string | Name of the solution to generate | Required, alphanumeric + hyphens, no spaces |
| `TARGET_DIRECTORY` | path | Where to create the solution | Must be empty or contain no .sln file |
| `SDK_VERSION` | string | .NET SDK version to require | Must match installed version format (e.g., 8.0.x) |

## Generated Entities

The scaffold produces the following entities in the generated solution:

### Solution

- **Type**: Container entity
- **Purpose**: Groups all projects under a single build
- **File**: `{SOLUTION_NAME}.sln`
- **Relationships**: References all src/* and tests/* projects

### Project: Domain

- **Type**: .NET class library
- **Path**: `src/Domain/{SOLUTION_NAME}.Domain.csproj`
- **Dependencies**: None (by design per constitution)
- **Contents**: Placeholders for aggregates, entities, value objects, domain events
- **Architecture Rule**: No outward dependencies; no framework references

### Project: Application

- **Type**: .NET class library
- **Path**: `src/Application/{SOLUTION_NAME}.Application.csproj`
- **Dependencies**: Domain
- **Contents**: Feature folders with CQRS handlers, validators, DTOs
- **Architecture Rule**: Depends only on Domain; defines ports/interfaces

### Project: Infrastructure

- **Type**: .NET class library
- **Path**: `src/Infrastructure/{SOLUTION_NAME}.Infrastructure.csproj`
- **Dependencies**: Application, Domain
- **Contents**: EF Core DbContext, repository implementations, external service clients
- **Architecture Rule**: Implements Application ports

### Project: Presentation

- **Type**: .NET web API (minimal API)
- **Path**: `src/Presentation/{SOLUTION_NAME}.Presentation.csproj`
- **Dependencies**: Application
- **Contents**: Program.cs, minimal API endpoints, middleware
- **Architecture Rule**: Depends only on Application

### Project: Domain.Tests

- **Type**: xUnit test project
- **Path**: `tests/Domain.Tests/{SOLUTION_NAME}.Domain.Tests.csproj`
- **Dependencies**: Domain, TUnit, FluentAssertions, NSubstitute
- **Contents**: Unit tests for domain objects

### Project: Application.Tests

- **Type**: xUnit test project
- **Path**: `tests/Application.Tests/{SOLUTION_NAME}.Application.Tests.csproj`
- **Dependencies**: Application, TUnit, FluentAssertions, NSubstitute
- **Contents**: Integration tests per slice

### Project: Architecture.Tests

- **Type**: xUnit test project
- **Path**: `tests/Architecture.Tests/{SOLUTION_NAME}.Architecture.Tests.csproj`
- **Dependencies**: All src/* projects, ArchUnitNET
- **Contents**: Dependency rule enforcement tests

## Makefile Targets

| Target | Purpose | Dependencies |
|--------|---------|---------------|
| `build` | Compile all projects | `dotnet build` |
| `test` | Run all test projects | `dotnet test` |
| `coverage` | Run tests with coverage, fail if <90% | `dotnet test --coverage` |
| `lint` | Run static analysis | `dotnet format verify` |
| `clean` | Remove build artifacts | `rm -rf bin/ obj/` |

## Security Artifacts Generated

| Artifact | Format | Purpose |
|----------|--------|---------|
| SBOM | CycloneDX JSON | Dependency inventory |
| SCA config | YAML | Vulnerability scanning |
| Secret scan config | YAML | Pre-commit/CI secrets detection |
| Code signing template | README section | Guidance only |
| Runtime hardening | README section | Guidance only |

## Observability Artifacts Generated

| Artifact | Purpose |
|----------|---------|
| OpenTelemetry setup | Tracing instrumentation |
| Prometheus metrics endpoint | Metrics collection |
| Grafana dashboard template | Visualization |
| CI threshold guidance | Alerting rules |

## State Transitions

The scaffold itself is stateless - it takes inputs and produces outputs. The generated solution follows standard .NET project lifecycle:
1. `dotnet new` → empty project
2. `dotnet build` → compiled assemblies
3. `dotnet test` → pass/fail

No runtime state transitions in the scaffold.
