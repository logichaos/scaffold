#!/bin/sh
# scaffold/scripts/lib/security.sh — Generate security hardening files

TMPL_DIR="${TMPL_DIR:-"${SCRIPT_DIR}/../templates"}"

generate_security() {
  log_info "Generating security scaffolding..."

  # .github/workflows/ci-security.yml
  GH_WORKFLOWS="${OUTPUT_DIR}/.github/workflows"
  mkdir -p "${GH_WORKFLOWS}"
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/ci-security.yml.tmpl" \
    > "${GH_WORKFLOWS}/ci-security.yml"
  log_verbose "Generated: ${GH_WORKFLOWS}/ci-security.yml"

  # .github/dependabot.yml
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/dependabot.yml.tmpl" \
    > "${OUTPUT_DIR}/.github/dependabot.yml"
  log_verbose "Generated: ${OUTPUT_DIR}/.github/dependabot.yml"

  # .gitleaks.toml
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/gitleaks.toml.tmpl" \
    > "${OUTPUT_DIR}/.gitleaks.toml"
  log_verbose "Generated: ${OUTPUT_DIR}/.gitleaks.toml"

  # scripts/sbom-generate.sh (executable helper)
  SCRIPTS_DIR="${OUTPUT_DIR}/scripts"
  mkdir -p "${SCRIPTS_DIR}"
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/sbom-generate.sh.tmpl" \
    > "${SCRIPTS_DIR}/sbom-generate.sh"
  chmod +x "${SCRIPTS_DIR}/sbom-generate.sh"
  log_verbose "Generated: ${SCRIPTS_DIR}/sbom-generate.sh"

  log_info "Security scaffolding generated."
}
