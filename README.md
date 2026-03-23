# .NET Project Scaffold

A POSIX shell script that generates a production-ready Clean Architecture .NET solution from a single command. No templates engine, no `dotnet new` — just a portable shell script that produces a fully compiling, test-passing project with hardened security defaults, optional observability, and quality-gate Makefiles.

## What Gets Generated

Running the scaffold creates a complete `.NET` solution under a directory of your choice:

```
<OutputDir>/
├── <Name>.slnx                        # Solution file (dotnet 10+) or .sln (dotnet <10)
├── Makefile                           # Quality gate targets: build, test, coverage, lint, clean
├── README.md                          # Project-specific documentation
├── global.json                        # Pins SDK major version + MTP test runner config
├── Directory.Build.props              # Nullable, WarningsAsErrors, LangVersion latest
├── Directory.Packages.props           # Central Package Management (all NuGet versions pinned)
├── .globalconfig                      # Analyzer rules (.editorconfig format)
├── .gitleaks.toml                     # Secret scanning config
├── .github/
│   ├── dependabot.yml                 # SCA — NuGet vulnerability scanning
│   └── workflows/
│       ├── ci-security.yml            # SCA scan + GitLeaks + SBOM generation gate
│       ├── ci-perf.yml                # CI budget annotations + flaky-test retry (--benchmarks)
│       └── ci-observability.yml       # Metric threshold guidance (--observability)
├── scripts/
│   └── sbom-generate.sh               # Generates sbom.cdx.json via dotnet-CycloneDX
├── src/
│   ├── Domain/                        # No third-party dependencies
│   ├── Application/                   # Mediator, FluentValidation; references Domain only
│   ├── Infrastructure/                # EF Core; references Application + Domain
│   └── Presentation/                  # ASP.NET Core minimal API; references Application only
├── tests/
│   ├── Domain.Tests/                  # TUnit + FluentAssertions + NSubstitute
│   ├── Application.Tests/             # TUnit + FluentAssertions + NSubstitute
│   └── Architecture.Tests/            # ArchUnitNET — enforces Clean Architecture rules
└── docs/
    └── dashboards/
        └── app-dashboard.json         # Grafana dashboard template (--observability)
```

Opt-in flags add:

| Flag | Additional output |
|---|---|
| `--benchmarks` | `tests/Benchmarks/` with BenchmarkDotNet project, `SampleBenchmark.cs`, `ci-perf.yml` workflow |
| `--observability` | `src/Presentation/OtelSetup.cs`, `PrometheusEndpoint.cs`, Grafana dashboard, `ci-observability.yml` workflow |

## Requirements

- **POSIX-compatible shell** — `sh`, `dash`, or `bash`
- **.NET SDK 8.0+** — the script detects the installed version and auto-selects the correct `TargetFramework` (`net8.0`, `net10.0`, etc.)
- **GNU Make** — for the generated quality gate targets
- **Internet access at scaffold time** — NuGet restore fetches packages during first `make build`

No other tools are required at scaffold time. Security tooling (`dotnet-CycloneDX`, `gitleaks`) is fetched on demand via generated scripts.

## Installation

No installation needed. Clone the repo and run `bootstrap.sh` directly:

```sh
git clone <repo-url>
cd scaffold
```

Or copy `scaffold/scripts/bootstrap.sh` and `scaffold/scripts/lib/` and `scaffold/templates/` to any location you prefer.

## Usage

```
scaffold/scripts/bootstrap.sh [OPTIONS]

Options:
  -n, --name <NAME>      Solution name (required)
                         Alphanumeric characters and hyphens only; no spaces
  -o, --output <PATH>    Output directory (required)
                         Created if it does not exist
  -s, --sdk <VERSION>    .NET SDK major version to target (default: 8.0)
                         Auto-upgraded if the installed SDK is newer
  -f, --force            Overwrite existing files in the output directory
      --benchmarks       Generate optional BenchmarkDotNet project
      --observability    Generate OpenTelemetry + Prometheus + Grafana scaffolding
  -v, --verbose          Enable verbose/debug output
  -h, --help             Show this help message and exit
```

### Minimal example

```sh
bash scaffold/scripts/bootstrap.sh \
  --name MyService \
  --output /tmp/my-service
```

### Full example with all opt-in features

```sh
bash scaffold/scripts/bootstrap.sh \
  --name MyService \
  --output ~/projects/my-service \
  --benchmarks \
  --observability
```

### Then build and test

```sh
cd ~/projects/my-service
make build   # dotnet build --configuration Release
make test    # dotnet test (all TUnit + ArchUnitNET tests)
make lint    # dotnet format --verify-no-changes
```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `DOTNET_SCAFFOLD_SDK_VERSION` | Override the default target SDK version | `8.0` |
| `DOTNET_SCAFFOLD_VERBOSE` | Set to `true` to enable verbose output without passing `-v` | `false` |

## Generated Makefile Targets

Every scaffolded project includes a `Makefile` with the following targets:

| Target | Description |
|---|---|
| `make build` | `dotnet build --configuration Release` |
| `make test` | `dotnet test` — runs TUnit unit tests and ArchUnitNET architecture compliance tests |
| `make coverage` | Runs tests with XPlat Code Coverage; fails if line coverage falls below 90% |
| `make lint` | `dotnet format --verify-no-changes`; non-zero exit if formatting violations exist |
| `make clean` | Removes all `bin/`, `obj/`, and `coverage-results/` directories |
| `make sbom` | Generates `sbom.cdx.json` using `dotnet-CycloneDX` (CycloneDX format) |
| `make benchmark` | Runs BenchmarkDotNet in Release mode (only if `--benchmarks` was used) |

## Architecture Enforcement

The generated `Architecture.Tests` project uses [ArchUnitNET](https://archunitnet.readthedocs.io/) to automatically enforce Clean Architecture dependency rules:

| Rule | Enforced by |
|---|---|
| Domain has no outward dependencies | `DomainLayer.Should().NotDependOn(ApplicationLayer)` etc. |
| Application does not reference Infrastructure | `ApplicationLayer.Should().NotDependOn(InfrastructureLayer)` |
| Presentation does not reference Domain directly | `PresentationLayer.Should().NotDependOn(DomainLayer)` |

Violating any rule causes `make test` to fail with a descriptive message identifying the offending dependency. This makes architecture drift impossible to accidentally ship.

## Exit Codes

| Code | Meaning |
|---|---|
| `0` | Success |
| `1` | General error |
| `2` | Invalid arguments (missing required flag, unknown flag, invalid solution name) |
| `3` | .NET SDK not found on `PATH`, or installed version is too old |
| `4` | Output directory already contains a solution — re-run with `--force` to overwrite |
| `5` | Permission denied when creating the output directory |

## Security Features

The scaffold generates a security-hardened baseline out of the box:

- **SBOM** — `make sbom` produces a `sbom.cdx.json` (CycloneDX JSON) via `dotnet-CycloneDX`
- **Dependabot** — `.github/dependabot.yml` is configured for NuGet weekly scanning
- **SCA** — `ci-security.yml` runs `dotnet list package --vulnerable --include-transitive` on every push
- **Secret scanning** — `.gitleaks.toml` pre-configured for .NET projects; `ci-security.yml` runs GitLeaks in CI
- **Runtime hardening checklist** — the generated `README.md` includes an 8-point runtime hardening reference

## Observability (`--observability`)

When the `--observability` flag is passed, the scaffold adds:

- **`OtelSetup.cs`** — extension method wiring OpenTelemetry tracing, metrics, and logging with OTLP export. Configured via environment variables:

  | Variable | Description |
  |---|---|
  | `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint (e.g. `http://localhost:4317`) |
  | `OTEL_SERVICE_NAME` | Service name in traces (defaults to the solution name) |

- **`PrometheusEndpoint.cs`** — exposes a `/metrics` scrape endpoint using `prometheus-net.AspNetCore`
- **`docs/dashboards/app-dashboard.json`** — Grafana dashboard template with panels for HTTP request rate, error rate, and p95 latency
- **`ci-observability.yml`** — GitHub Actions workflow with guidance comments for metric threshold alerting

NuGet packages added to `Presentation.csproj`:
`OpenTelemetry.Extensions.Hosting`, `OpenTelemetry.Instrumentation.AspNetCore`, `OpenTelemetry.Instrumentation.Http`, `OpenTelemetry.Instrumentation.Runtime`, `OpenTelemetry.Exporter.OpenTelemetryProtocol`, `prometheus-net.AspNetCore`

## Performance Benchmarks (`--benchmarks`)

When the `--benchmarks` flag is passed, the scaffold adds:

- **`tests/Benchmarks/`** — a BenchmarkDotNet project with a `SampleBenchmark.cs` stub and documented SLA targets:
  - p95 latency < 200 ms
  - p99 latency < 500 ms
  - Throughput ≥ 1,000 RPS (in-process operations)
- **`make benchmark`** — runs benchmarks in Release mode
- **`ci-perf.yml`** — GitHub Actions workflow with:
  - 5-minute build+test budget (emits `::warning::` if exceeded — no hard fail)
  - `--retry-failed-max-count 2` for flaky-test detection

## Running the Test Suite

The repository includes 5 shell integration tests for the scaffold itself:

```sh
make test
```

| Test script | What it validates |
|---|---|
| `test_invalid_args.sh` | Correct exit codes for all invalid argument combinations |
| `test_prerequisites.sh` | Exit code `3` when `dotnet` is absent from `PATH` |
| `test_idempotency.sh` | Exit code `4` on double-run; `--force` succeeds; `make build` passes after re-run |
| `test_makefile_targets.sh` | All generated Makefile targets produce correct exit codes |
| `test_arch_violations.sh` | Clean scaffold passes; injected architecture violation causes `make test` to fail |

All tests scaffold real projects into `/tmp`, run actual `dotnet` commands, and clean up on exit.

## Compatibility Notes

- The scaffold auto-detects the installed .NET SDK major version. If a newer SDK is installed than the version requested (e.g. SDK 10 when `--sdk 8.0` is specified), the scaffold silently upgrades `TargetFramework` to match the installed SDK.
- `.NET 10+` generates `.slnx` solution files instead of `.sln`. The generated `Makefile` handles both formats automatically via `$(firstword $(wildcard ...))`.
- The `dotnet test` command uses `--solution` syntax required by the [Microsoft Testing Platform (MTP)](https://learn.microsoft.com/en-us/dotnet/core/testing/microsoft-testing-platform-intro) runner used by TUnit.

## Project Layout (this repo)

```
scaffold/
├── scripts/
│   ├── bootstrap.sh         # Main entry point — sources all lib modules
│   └── lib/
│       ├── log.sh            # log_info / log_warn / log_error / log_verbose
│       ├── args.sh           # CLI argument parser and validation
│       ├── prereqs.sh        # .NET SDK version check
│       ├── idempotency.sh    # Existing-solution guard
│       ├── projects.sh       # .csproj generation + render_template helper
│       ├── solution.sh       # dotnet sln / slnx creation
│       ├── buildprops.sh     # Directory.Build.props, Directory.Packages.props, global.json
│       ├── makefile.sh       # Generated Makefile
│       ├── readme.sh         # Generated README.md
│       ├── archtests.sh      # ArchUnitNET test class + AssemblyMarker stubs
│       ├── security.sh       # GitLeaks, Dependabot, CI security workflow, SBOM script
│       ├── benchmarks.sh     # BenchmarkDotNet project (opt-in)
│       └── observability.sh  # OpenTelemetry + Prometheus + Grafana (opt-in)
├── templates/                # 24 .tmpl files — substitution tokens: {{SOLUTION_NAME}}, {{TARGET_FRAMEWORK}}
└── tests/                    # 5 POSIX sh integration tests
specs/
└── 001-dotnet-scaffold/
    ├── spec.md               # Feature specification
    ├── plan.md               # Technical implementation plan
    └── tasks.md              # Task breakdown (all T001–T061 complete)
```
