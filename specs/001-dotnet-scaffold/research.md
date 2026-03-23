# Research: .NET Project Scaffold

## Decision: Shell Script Implementation

**Rationale**: The constitution explicitly states the scaffold is implemented as a shell script (not a `dotnet new` template). This allows maximum portability across Linux/macOS/WSL without requiring .NET SDK installation for the scaffold itself.

**Alternatives considered**:
- `dotnet new` template: Rejected per constitution assumption (FR-010 explicitly states shell script)
- PowerShell: Rejected - cross-platform POSIX preferred
- Python: Overkill - shell script sufficient for template expansion

## Decision: SBOM Format

**Rationale**: CycloneDX is chosen over SPDX for better .NET ecosystem tooling support (compatibility with NuGet, OWASP dependency tracking).

**Alternatives considered**:
- SPDX: More verbose, less tooling in .NET space
- CycloneDX (chosen): Compact JSON, strong tool support, OWASP-integrated

## Decision: SCA Tooling

**Rationale**: Dependabot is the standard for GitHub-native vulnerability scanning. For CI-agnostic scenarios, include dotnet-outdated or equivalent as fallback.

**Alternatives considered**:
- GitHub Advisory Database + Dependabot (chosen): Native integration, minimal config
- Snyk: Requires separate service
- OWASP Dependency Check: Java-heavy, less optimal for .NET

## Decision: Secret Scanning

**Rationale**: GitLeaks provides excellent pre-commit and CI integration with minimal configuration.

**Alternatives considered**:
- GitLeaks (chosen): Fast, low false-positive rate, pre-commit compatible
- TruffleHog: More thorough but slower
- Native GitHub secrets scanning: Complementary, not replacement for pre-commit

## Decision: Runtime Benchmark Tool

**Rationale**: BenchmarkDotNet is the industry standard for .NET performance testing. The scaffold will include template projects that reference it.

**Alternatives considered**:
- BenchmarkDotNet (chosen): Official .NET foundation project, comprehensive reporting
- wrk/k6: External tools, not .NET-native

## Decision: Observability Stack

**Rationale**: OpenTelemetry provides vendor-neutral instrumentation; Prometheus + Grafana provide the visualization layer. This combination is industry standard and constitution-compatible.

**Alternatives considered**:
- OpenTelemetry + Prometheus + Grafana (chosen): Vendor-neutral, widely supported
- Application Insights: Azure-locked
- DataDog: Expensive, vendor-locked
