# Quickstart: .NET Project Scaffold

## Prerequisites

- .NET SDK 8.0 or later installed
- GNU Make (Linux/macOS) or WSL on Windows
- Git (for version control)

## Quick Start

```bash
# Clone the scaffold repository
git clone https://github.com/yourorg/dotnet-scaffold.git
cd dotnet-scaffold

# Run the scaffold to generate a new solution
./scaffold.sh --name MyNewProject --output ./myproject

# Navigate to generated solution
cd myproject

# Build the solution
make build

# Run tests
make test

# View coverage report
make coverage

# Clean build artifacts
make clean
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make build` | Compiles all projects in the solution |
| `make test` | Runs all test suites |
| `make coverage` | Runs tests with coverage, fails if <90% |
| `make lint` | Runs static analysis |
| `make clean` | Removes bin/ and obj/ directories |

## Project Structure

After scaffolding, your solution will have this structure:

```
myproject/
├── src/
│   ├── Domain/           # Domain entities, value objects, events
│   ├── Application/      # Use cases, handlers, DTOs
│   ├── Infrastructure/   # EF Core, external services
│   └── Presentation/     # API endpoints
├── tests/
│   ├── Domain.Tests/     # Unit tests
│   ├── Application.Tests/ # Integration tests
│   └── Architecture.Tests/ # Architecture compliance
├── Makefile
└── README.md
```

## Security Features

The scaffold includes:
- **SBOM**: Generated as `sbom.cdx.json` in solution root
- **SCA**: Dependabot configuration in `.github/dependabot.yml`
- **Secret Scanning**: GitLeaks configuration in `.gitleaks.toml`
- **Vulnerability CI Gate**: Builds fail on Critical/High vulnerabilities

## Performance Features

The scaffold includes:
- **CI Time Budget**: Default 5-minute budget (warns if exceeded)
- **Runtime Benchmarks**: Optional BenchmarkDotNet template
- **Flaky Test Detection**: Rerun failed tests in CI

## Observability Features

The scaffold includes:
- **OpenTelemetry**: Tracing instrumentation in Presentation layer
- **Prometheus**: Metrics endpoint at `/metrics`
- **Grafana**: Dashboard template in `docs/dashboards/`

## Adding Your First Feature

```bash
# Create a new feature in Application layer
cd src/Application/Features
# Add your feature folder with Command, Query, Handler, Validator
```

## Next Steps

1. Review the generated `README.md`
2. Configure your CI/CD (GitHub Actions templates included)
3. Begin adding domain logic to the Domain project
4. Write your first test

## Troubleshooting

### "SDK not found" error
Ensure .NET SDK 8.0+ is installed: `dotnet --version`

### "Solution already exists" error
Choose a different output directory or remove existing .sln file

### Coverage below 90%
Add more tests to increase coverage, or adjust threshold in Makefile
