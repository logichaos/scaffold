#!/bin/sh
# scaffold/scripts/bootstrap.sh — Main scaffold entry point
# Usage: bootstrap.sh --name <NAME> --output <PATH> [OPTIONS]
set -eu

# Resolve script directory without relying on external 'dirname' command
_s="$0"
case "${_s}" in
  /*) SCRIPT_DIR="${_s%/*}" ;;
  */*) SCRIPT_DIR="$(cd "${_s%/*}" && pwd)" ;;
  *) SCRIPT_DIR="$(pwd)" ;;
esac
unset _s
TMPL_DIR="${SCRIPT_DIR}/../templates"
export SCRIPT_DIR TMPL_DIR
LIB_DIR="${SCRIPT_DIR}/lib"

# shellcheck source=lib/log.sh
. "${LIB_DIR}/log.sh"
# shellcheck source=lib/args.sh
. "${LIB_DIR}/args.sh"
# shellcheck source=lib/prereqs.sh
. "${LIB_DIR}/prereqs.sh"
# shellcheck source=lib/idempotency.sh
. "${LIB_DIR}/idempotency.sh"
# shellcheck source=lib/projects.sh
. "${LIB_DIR}/projects.sh"
# shellcheck source=lib/solution.sh
. "${LIB_DIR}/solution.sh"
# shellcheck source=lib/buildprops.sh
. "${LIB_DIR}/buildprops.sh"
# shellcheck source=lib/makefile.sh
. "${LIB_DIR}/makefile.sh"
# shellcheck source=lib/readme.sh
. "${LIB_DIR}/readme.sh"
# shellcheck source=lib/archtests.sh
. "${LIB_DIR}/archtests.sh"
# shellcheck source=lib/security.sh
. "${LIB_DIR}/security.sh"
# shellcheck source=lib/benchmarks.sh
. "${LIB_DIR}/benchmarks.sh"
# shellcheck source=lib/observability.sh
. "${LIB_DIR}/observability.sh"

main() {
  parse_args "$@"
  check_prereqs
  check_idempotency
  generate_projects
  generate_solution
  generate_buildprops
  generate_makefile
  generate_readme
  generate_archtests
  generate_security
  if [ "${ENABLE_BENCHMARKS:-false}" = "true" ]; then
    generate_benchmarks
  fi
  if [ "${ENABLE_OBSERVABILITY:-false}" = "true" ]; then
    generate_observability
  fi
  log_info "Scaffold complete. Run: cd ${OUTPUT_DIR} && make build && make test"
}

main "$@"
