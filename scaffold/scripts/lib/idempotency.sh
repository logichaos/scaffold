#!/bin/sh
# scaffold/scripts/lib/idempotency.sh — Guard against overwriting existing scaffolds

check_idempotency() {
  log_info "Checking target directory: ${OUTPUT_DIR}"

  if [ -d "${OUTPUT_DIR}" ]; then
    # Check for existing .sln or .slnx file (ls fails if one glob has no match, so test separately)
    _found_sln=false
    ls "${OUTPUT_DIR}"/*.sln  >/dev/null 2>&1 && _found_sln=true
    ls "${OUTPUT_DIR}"/*.slnx >/dev/null 2>&1 && _found_sln=true
    if [ "${_found_sln}" = "true" ]; then
      if [ "${FORCE}" = "true" ]; then
        log_warn "Existing solution found in ${OUTPUT_DIR}. --force provided, proceeding (files will be overwritten)."
      else
        log_error "A solution file (.sln/.slnx) already exists in '${OUTPUT_DIR}'."
        log_error "To overwrite, re-run with --force. To use a different location, change --output."
        exit 4
      fi
    fi
  else
    # Create target directory
    if ! mkdir -p "${OUTPUT_DIR}" 2>/dev/null; then
      log_error "Cannot create output directory '${OUTPUT_DIR}'. Check permissions."
      exit 5
    fi
    log_verbose "Created output directory: ${OUTPUT_DIR}"
  fi

  log_info "Target directory OK: ${OUTPUT_DIR}"
}
