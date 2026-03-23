#!/bin/sh
# scaffold/scripts/lib/readme.sh — Generate README.md from template

TMPL_DIR="${TMPL_DIR:-"${SCRIPT_DIR}/../templates"}"

generate_readme() {
  log_info "Generating README.md..."
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/README.md.tmpl" > "${OUTPUT_DIR}/README.md"
  log_info "README.md generated."
}
