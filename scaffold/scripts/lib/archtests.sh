#!/bin/sh
# scaffold/scripts/lib/archtests.sh — Generate ArchUnitNET architecture compliance tests

TMPL_DIR="${TMPL_DIR:-"${SCRIPT_DIR}/../templates"}"

generate_archtests() {
  log_info "Generating architecture tests..."

  ARCH_TEST_DIR="${OUTPUT_DIR}/tests/Architecture.Tests"

  # Generate ArchitectureTests.cs from template with namespace substitution
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/ArchitectureTests.cs.tmpl" \
    > "${ARCH_TEST_DIR}/ArchitectureTests.cs"

  log_verbose "Generated: ${ARCH_TEST_DIR}/ArchitectureTests.cs"

  # Generate AssemblyMarker.cs in each src project (required by ArchUnitNET reflective loading)
  for layer in Domain Application Infrastructure Presentation; do
    marker_file="${OUTPUT_DIR}/src/${layer}/AssemblyMarker.cs"
    cat > "${marker_file}" <<CSEOF
namespace ${SOLUTION_NAME}.${layer};

/// <summary>
/// Marker type used by ArchUnitNET to locate this assembly during architecture tests.
/// Do not remove or rename this class.
/// </summary>
public sealed class AssemblyMarker { }
CSEOF
    log_verbose "Generated: ${marker_file}"
  done

  log_info "Architecture tests generated."
}
