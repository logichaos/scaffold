# Tasks: .NET Project Scaffold

**Input**: Design documents from `/specs/001-dotnet-scaffold/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/cli.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Repository scaffolding and tool initialization for the scaffold project itself.

- [x] T001 Create top-level directory structure: `scaffold/`, `scaffold/scripts/`, `scaffold/templates/`, `scaffold/tests/` at repository root
- [x] T002 [P] Create `scaffold/scripts/bootstrap.sh` as the main entry point (empty stub with POSIX shebang, `set -euo pipefail`)
- [x] T003 [P] Create `scaffold/scripts/lib/` for shared shell library functions: argument parsing, logging, validation
- [x] T004 [P] Create root `Makefile` with targets: `build`, `test`, `coverage`, `lint`, `clean` (stubbed, failing) per spec FR-004
- [x] T005 [P] Add `.editorconfig` at repository root for consistent editor settings across all projects and contributors

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core scaffold machinery that ALL user stories depend on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T006 Implement CLI argument parser in `scaffold/scripts/lib/args.sh` with: `--name`, `--output`, `--sdk`, `--force`, `--verbose`, `--help` per `contracts/cli.md`
- [x] T007 Implement SDK prerequisite checker in `scaffold/scripts/lib/prereqs.sh`: verify `dotnet` is on PATH, validate version format, emit human-readable error and exit code `3` if missing
- [x] T008 Implement idempotency guard in `scaffold/scripts/lib/idempotency.sh`: detect existing `.sln` in target directory, exit code `4` with clear message if found and `--force` not provided
- [x] T009 [P] Implement logging helper in `scaffold/scripts/lib/log.sh`: `log_info`, `log_warn`, `log_error` functions respecting `--verbose` flag
- [x] T010 [P] Create `scaffold/templates/` directory with template stubs: `solution.sln.tmpl`, `Directory.Build.props.tmpl`, `Directory.Packages.props.tmpl`, `.globalconfig.tmpl`
- [x] T011 Wire `scaffold/scripts/bootstrap.sh` to call `prereqs.sh`, `idempotency.sh`, then `args.sh` in correct order; ensure all exit codes propagate

**Checkpoint**: Foundation ready — user story phases can now begin.

---

## Phase 3: User Story 1 — Bootstrap a new .NET project (Priority: P1) 🎯 MVP

**Goal**: Developer runs a single command on an empty directory and gets a fully compiling, test-passing .NET solution with all Clean Architecture layers.

**Independent Test**: `./scaffold/scripts/bootstrap.sh --name MyProject --output /tmp/test-scaffold && cd /tmp/test-scaffold && make build && make test` — all steps must succeed.

### Implementation for User Story 1

- [x] T012 [P] [US1] Create `.csproj` template for Domain project in `scaffold/templates/Domain.csproj.tmpl` with no third-party references per FR-008
- [x] T013 [P] [US1] Create `.csproj` template for Application project in `scaffold/templates/Application.csproj.tmpl` referencing Domain; include Mediator, FluentValidation NuGet packages
- [x] T014 [P] [US1] Create `.csproj` template for Infrastructure project in `scaffold/templates/Infrastructure.csproj.tmpl` referencing Application + Domain; include EF Core NuGet packages
- [x] T015 [P] [US1] Create `.csproj` template for Presentation project in `scaffold/templates/Presentation.csproj.tmpl` referencing Application only; minimal API entrypoint
- [x] T016 [P] [US1] Create `.csproj` template for Domain.Tests in `scaffold/templates/Domain.Tests.csproj.tmpl` referencing Domain + TUnit + FluentAssertions + NSubstitute
- [x] T017 [P] [US1] Create `.csproj` template for Application.Tests in `scaffold/templates/Application.Tests.csproj.tmpl` referencing Application + TUnit + FluentAssertions + NSubstitute
- [x] T018 [P] [US1] Create `.csproj` template for Architecture.Tests in `scaffold/templates/Architecture.Tests.csproj.tmpl` referencing all src projects + ArchUnitNET
- [x] T019 [US1] Implement `scaffold/scripts/lib/projects.sh`: function to instantiate each `.csproj.tmpl` with `SOLUTION_NAME` substitution and write to correct `src/` or `tests/` path per FR-002 and FR-003
- [x] T020 [US1] Implement `scaffold/scripts/lib/solution.sh`: create `.sln` file using `dotnet sln add` for all generated projects per FR-001
- [x] T021 [US1] Add placeholder source files per project: `src/Domain/ReadMe.md`, `src/Application/Features/.gitkeep`, `src/Infrastructure/ReadMe.md`, `src/Presentation/Program.cs` (minimal valid stub)
- [x] T022 [US1] Implement `scaffold/scripts/lib/buildprops.sh`: generate `Directory.Build.props` (nullable enable, warnings as errors, LangVersion latest) and `Directory.Packages.props` (centrally managed NuGet versions) per FR-007
- [x] T023 [US1] Wire all Phase 3 generators into `scaffold/scripts/bootstrap.sh` main execution flow; verify `dotnet build` succeeds end-to-end on generated solution

**Checkpoint**: `make build && make test` passes on a freshly scaffolded empty-directory run.

---

## Phase 4: User Story 2 — Quality Gates via Makefile (Priority: P2)

**Goal**: Developer can run `make build`, `make test`, `make coverage`, `make lint`, `make clean` without knowing underlying CLI invocations.

**Independent Test**: Execute each Makefile target against scaffolded solution; verify expected output and exit code.

### Implementation for User Story 2

- [x] T024 [US2] Implement `scaffold/scripts/lib/makefile.sh`: generate `Makefile` with all required targets (build, test, coverage, lint, clean) per FR-004; use `$(DOTNET)` variable for SDK path
- [x] T025 [US2] Implement `coverage` target in generated `Makefile`: invoke `dotnet test --collect:"XPlat Code Coverage"`, parse threshold, fail if below 90% per FR-005; emit clear error message for empty test suite edge case
- [x] T026 [US2] Implement `lint` target in generated `Makefile`: invoke `dotnet format --verify-no-changes`; treat non-zero exit as build failure per FR-007 acceptance
- [x] T027 [US2] Implement `clean` target in generated `Makefile`: remove `bin/`, `obj/`, coverage report directories at all project levels per acceptance scenario 3
- [x] T028 [US2] Add `scaffold/templates/README.md.tmpl`: template for generated `README.md` describing all Makefile targets, project structure, and usage per FR-009
- [x] T029 [US2] Integrate Makefile and README generation into `scaffold/scripts/bootstrap.sh` execution flow
- [x] T030 [US2] Add `scaffold/tests/test_makefile_targets.sh`: shell-level integration test that scaffolds a solution and validates each Makefile target exit code

**Checkpoint**: All Makefile targets execute successfully on fresh scaffold output without manual configuration.

---

## Phase 5: User Story 3 — Architecture Compliance Tests (Priority: P3)

**Goal**: `Architecture.Tests` project contains pre-written ArchUnitNET tests that automatically fail `make test` when Clean Architecture dependency rules are violated.

**Independent Test**: Scaffold a solution, deliberately add `using Infrastructure` in `Domain` project, run `make test` — architecture tests must fail with an identifying error message.

### Implementation for User Story 3

- [x] T031 [US3] Implement `scaffold/templates/ArchitectureTests.cs.tmpl`: template file generating ArchUnitNET test class with assertions for all four rules in FR-006:
  - Domain has no outward dependencies
  - Application does not reference Infrastructure
  - Presentation does not reference Domain directly
  - (Each rule as a separate `[Test]` method)
- [x] T032 [US3] Implement `scaffold/scripts/lib/archtests.sh`: instantiate `ArchitectureTests.cs.tmpl` into `tests/Architecture.Tests/ArchitectureTests.cs` with correct namespace substitution
- [x] T033 [US3] Wire architecture test generation into `scaffold/scripts/bootstrap.sh`; verify `make test` passes on clean scaffold
- [x] T034 [US3] Add `scaffold/tests/test_arch_violations.sh`: shell test that scaffolds a solution, injects a Domain→Infrastructure dependency, runs `make test`, and asserts non-zero exit with descriptive message per acceptance scenario 2

**Checkpoint**: Architecture tests pass on clean scaffold; violating references reliably fail `make test`.

---

## Phase 6: Security Hardening (NFR-SEC-001 — NFR-SEC-003)

**Goal**: Scaffold generates SBOM, SCA/Dependabot config, GitLeaks secret scanning config, and runtime hardening guidance.

**Independent Test**: Run scaffold; confirm `sbom.cdx.json`, `.github/dependabot.yml`, `.gitleaks.toml`, and hardening section in `README.md` are all present and well-formed.

### Implementation for Phase 6

- [x] T035 [P] Implement `scaffold/templates/sbom-generate.sh.tmpl`: shell script template that calls `dotnet CycloneDX` to produce `sbom.cdx.json` in solution root; add `make sbom` target to generated Makefile per NFR-SEC-001
- [x] T036 [P] Implement `scaffold/templates/dependabot.yml.tmpl`: Dependabot config for NuGet ecosystem scanning; fail CI on Critical/High per NFR-SEC-002
- [x] T037 [P] Implement `scaffold/templates/gitleaks.toml.tmpl`: GitLeaks config template with sensible .NET defaults per NFR-SEC-003; add pre-commit hook instructions to generated `README.md`
- [x] T038 [P] Implement `scaffold/templates/ci-security.yml.tmpl`: GitHub Actions workflow template with SCA scan step (runs `dotnet list package --vulnerable`), GitLeaks scan, and SBOM generation gate
- [x] T039 [US2] Extend `scaffold/templates/README.md.tmpl` with Security section: secret handling procedure, code-signing guidance, runtime hardening checklist per NFR-SEC-001 and NFR-SEC-003
- [x] T040 Implement `scaffold/scripts/lib/security.sh`: instantiate all security templates into their correct output paths during bootstrap
- [x] T041 Wire `security.sh` into `scaffold/scripts/bootstrap.sh` execution flow

**Checkpoint**: Fresh scaffold output includes all security artifacts; SCA gate fails for known-vulnerable package (manual verification).

---

## Phase 7: Performance Benchmarks & CI Budgets (NFR-PERF-001 — NFR-PERF-003)

**Goal**: Scaffold generates CI build-time budget annotations, optional BenchmarkDotNet benchmark project template, and flaky-test detection hooks.

**Independent Test**: Run scaffold; confirm `make benchmark` target exists, benchmark project template is present, CI workflow includes timing annotations and retry-on-failure for flaky tests.

### Implementation for Phase 7

- [x] T042 [P] Implement `scaffold/templates/Benchmarks.csproj.tmpl`: optional benchmark project referencing BenchmarkDotNet; placed at `tests/Benchmarks/` per NFR-PERF-002
- [x] T043 [P] Implement `scaffold/templates/SampleBenchmark.cs.tmpl`: sample BenchmarkDotNet harness with documented p95/p99 targets (200ms / 500ms) and RPS guidance comment per NFR-PERF-002
- [x] T044 [P] Extend generated `Makefile` template (`scaffold/scripts/lib/makefile.sh`) with `benchmark` target invoking BenchmarkDotNet; target is opt-in (no-op if Benchmarks project absent)
- [x] T045 [P] Implement `scaffold/templates/ci-perf.yml.tmpl`: GitHub Actions workflow fragment annotating build+test step with 5-minute timeout and `::warning::` output if exceeded per NFR-PERF-001 (warn only, no hard fail)
- [x] T046 [P] Implement flaky-test detection in CI template (`scaffold/templates/ci-perf.yml.tmpl`): add `retry-on-failure: 2` and `dotnet test --retry-failed-max-count 2` flags per NFR-PERF-003
- [x] T047 Implement `scaffold/scripts/lib/benchmarks.sh`: instantiate benchmark templates; add `--benchmarks` flag to `bootstrap.sh` CLI to opt-in benchmark project generation
- [x] T048 Wire `benchmarks.sh` into `scaffold/scripts/bootstrap.sh` behind `--benchmarks` flag

**Checkpoint**: `./bootstrap.sh --name Foo --output /tmp/foo --benchmarks && make benchmark` completes without error.

---

## Phase 8: Full Observability Scaffolding (NFR-OBS-001)

**Goal**: Scaffold generates OpenTelemetry tracing setup, Prometheus metrics endpoint, Grafana dashboard template, and CI threshold guidance.

**Independent Test**: Scaffold with `--observability` flag; confirm `src/Presentation/Program.cs` contains OTel setup, `/metrics` endpoint present, `docs/dashboards/` contains Grafana JSON template.

### Implementation for Phase 8

- [x] T049 [P] Implement `scaffold/templates/otel-setup.cs.tmpl`: C# snippet template adding `AddOpenTelemetry()` to DI container in `Program.cs`; includes OTLP exporter placeholder
- [x] T050 [P] Implement `scaffold/templates/prometheus-endpoint.cs.tmpl`: C# snippet for `app.MapPrometheusScrapingEndpoint()` wired at `/metrics`; references `OpenTelemetry.Exporter.Prometheus.AspNetCore` NuGet
- [x] T051 [P] Implement `scaffold/templates/grafana-dashboard.json.tmpl`: minimal Grafana dashboard JSON with panels for HTTP request rate, error rate, p95 latency; placed in `docs/dashboards/app-dashboard.json`
- [x] T052 [P] Implement `scaffold/templates/ci-observability.yml.tmpl`: GitHub Actions workflow fragment with guidance comments for metric threshold alerts per NFR-OBS-001
- [x] T053 Implement `scaffold/scripts/lib/observability.sh`: instantiate observability templates; integrate OTel NuGet refs into Presentation `.csproj.tmpl`; add `--observability` flag to CLI
- [x] T054 Wire `observability.sh` into `scaffold/scripts/bootstrap.sh` behind `--observability` flag

**Checkpoint**: `./bootstrap.sh --name Foo --output /tmp/foo --observability && make build` succeeds; `/metrics` route visible in generated `Program.cs`.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Edge case handling, idempotency hardening, and final validation.

- [x] T055 [P] Implement empty-test-suite guard in generated `coverage` Makefile target: detect 0 tests found, emit `coverage: no tests found — failing at 0% (threshold 90%)`, exit non-zero per Edge Case spec
- [x] T056 [P] Implement `scaffold/tests/test_prerequisites.sh`: test that `bootstrap.sh` exits code `3` with readable message when `dotnet` is not on PATH
- [x] T057 [P] Implement `scaffold/tests/test_idempotency.sh`: test that running `bootstrap.sh` twice on the same directory exits code `4` without modifying existing files (unless `--force`); test that `--force` succeeds
- [x] T058 [P] Implement `scaffold/tests/test_invalid_args.sh`: test all invalid-argument scenarios; verify correct exit codes `1`, `2` per `contracts/cli.md`
- [x] T059 Update root `Makefile` `test` target to run all `scaffold/tests/*.sh` test scripts with TAP-compatible output
- [x] T060 [P] Update `scaffold/templates/README.md.tmpl` to include Observability, Security, and Benchmark sections from quickstart.md
- [x] T061 Final validation: run `scaffold/scripts/bootstrap.sh --name FullDemo --output /tmp/full-demo --benchmarks --observability` and verify `make build && make test && make coverage && make lint` all pass in under 5 minutes per SC-001 and SC-002

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — BLOCKS all user story phases
- **Phase 3 (US1 Bootstrap)**: Depends on Phase 2
- **Phase 4 (US2 Makefile)**: Depends on Phase 3 (needs generated projects to test targets against)
- **Phase 5 (US3 Arch Tests)**: Depends on Phase 3 (needs Architecture.Tests project scaffolded)
- **Phase 6 (Security)**: Depends on Phase 4 (README template must exist before extending)
- **Phase 7 (Benchmarks)**: Depends on Phase 4 (Makefile template must exist)
- **Phase 8 (Observability)**: Depends on Phase 3 (Presentation project template must exist)
- **Phase 9 (Polish)**: Depends on Phases 3–8

### User Story Dependencies

- **US1 (P1)**: Can start after Phase 2 — no story dependencies
- **US2 (P2)**: Depends on US1 (needs generated project files to test Makefile targets)
- **US3 (P3)**: Depends on US1 (needs Architecture.Tests project to be generated)
- **NFR phases (6–8)**: Can proceed in parallel after US2 completes

### Within Each Phase

- Tasks marked `[P]` within the same phase can execute concurrently (different files, no shared state)
- Template creation tasks (`[P]`) are all independent of each other
- Library (`lib/*.sh`) function tasks depend on their specific template tasks

### Parallel Opportunities

```bash
# Phase 3 — all .csproj templates can be created in parallel:
T012  # Domain.csproj.tmpl
T013  # Application.csproj.tmpl
T014  # Infrastructure.csproj.tmpl
T015  # Presentation.csproj.tmpl
T016  # Domain.Tests.csproj.tmpl
T017  # Application.Tests.csproj.tmpl
T018  # Architecture.Tests.csproj.tmpl

# Phase 6 — all security templates can be created in parallel:
T035  # sbom-generate.sh.tmpl
T036  # dependabot.yml.tmpl
T037  # gitleaks.toml.tmpl
T038  # ci-security.yml.tmpl

# Phase 7 — all performance templates can be created in parallel:
T042  # Benchmarks.csproj.tmpl
T043  # SampleBenchmark.cs.tmpl
T045  # ci-perf.yml.tmpl
T046  # flaky-test detection in ci-perf.yml.tmpl
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (T012–T023)
4. **STOP and VALIDATE**: `./scaffold/scripts/bootstrap.sh --name MVP --output /tmp/mvp && make build && make test`
5. Demo: developer can go zero → working .NET solution in one command

### Incremental Delivery

1. Phase 1 + 2 → CLI machinery ready
2. Phase 3 → Bootstrap works (US1 MVP)
3. Phase 4 → Makefile quality gates work (US2)
4. Phase 5 → Architecture compliance enforced (US3)
5. Phase 6 → Security hardening complete
6. Phase 7 → Performance benchmarks + CI budgets
7. Phase 8 → Full observability scaffold
8. Phase 9 → Edge cases, polish, final validation

---

## Notes

- `[P]` tasks = different files, no write-time conflicts — safe to run concurrently
- `[USn]` label maps each task to the user story it directly delivers value for
- Constitution compliance built into template content (not a post-processing step)
- Security (Phase 6) and Observability (Phase 8) use opt-in flags to avoid bloating minimal scaffold usage
- Performance budgets (Phase 7) emit warnings — hard failures are deferred to project-level policy
