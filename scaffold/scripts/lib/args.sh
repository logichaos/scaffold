#!/bin/sh
# scaffold/scripts/lib/args.sh — CLI argument parser
# Exports: SOLUTION_NAME, OUTPUT_DIR, SDK_VERSION, FORCE, VERBOSE, ENABLE_BENCHMARKS, ENABLE_OBSERVABILITY

SOLUTION_NAME=""
OUTPUT_DIR=""
SDK_VERSION="${DOTNET_SCAFFOLD_SDK_VERSION:-8.0}"
FORCE=false
VERBOSE="${DOTNET_SCAFFOLD_VERBOSE:-false}"
ENABLE_BENCHMARKS=false
ENABLE_OBSERVABILITY=false

usage() {
  cat <<EOF
Usage: bootstrap.sh [OPTIONS]

Options:
  -n, --name <NAME>          Solution name (required)
  -o, --output <PATH>        Output directory (required)
  -s, --sdk <VERSION>        .NET SDK version (default: ${SDK_VERSION})
  -f, --force                Overwrite existing files
      --benchmarks           Generate optional BenchmarkDotNet project
      --observability        Generate OpenTelemetry/Prometheus/Grafana scaffolding
  -v, --verbose              Enable verbose output
  -h, --help                 Show this help message

Exit codes:
  0  Success
  1  General error
  2  Invalid arguments
  3  SDK not found
  4  Target directory not empty (use --force to overwrite)
  5  Permission denied
EOF
}

parse_args() {
  if [ $# -eq 0 ]; then
    usage
    exit 2
  fi

  while [ $# -gt 0 ]; do
    case "$1" in
      -n|--name)
        shift
        SOLUTION_NAME="${1:?ERROR: --name requires a value}"
        ;;
      -o|--output)
        shift
        OUTPUT_DIR="${1:?ERROR: --output requires a value}"
        ;;
      -s|--sdk)
        shift
        SDK_VERSION="${1:?ERROR: --sdk requires a value}"
        ;;
      -f|--force)
        FORCE=true
        ;;
      --benchmarks)
        ENABLE_BENCHMARKS=true
        ;;
      --observability)
        ENABLE_OBSERVABILITY=true
        ;;
      -v|--verbose)
        VERBOSE=true
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        usage
        exit 2
        ;;
    esac
    shift
  done

  # Validate required args
  if [ -z "${SOLUTION_NAME}" ]; then
    log_error "--name is required"
    exit 2
  fi
  if [ -z "${OUTPUT_DIR}" ]; then
    log_error "--output is required"
    exit 2
  fi

  # Validate solution name: alphanumeric + hyphens only, no spaces
  case "${SOLUTION_NAME}" in
    *[!A-Za-z0-9-]*)
      log_error "Solution name must contain only alphanumeric characters and hyphens: '${SOLUTION_NAME}'"
      exit 2
      ;;
  esac

  export SOLUTION_NAME OUTPUT_DIR SDK_VERSION FORCE VERBOSE ENABLE_BENCHMARKS ENABLE_OBSERVABILITY
}
