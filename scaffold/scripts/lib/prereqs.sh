#!/bin/sh
# scaffold/scripts/lib/prereqs.sh — SDK prerequisite checker

check_prereqs() {
  log_info "Checking prerequisites..."

  # Verify dotnet is on PATH
  if ! command -v dotnet >/dev/null 2>&1; then
    log_error "dotnet SDK not found on PATH."
    log_error "Install .NET SDK ${SDK_VERSION} from https://dotnet.microsoft.com/download"
    exit 3
  fi

  # Get installed version
  INSTALLED_VERSION="$(dotnet --version 2>/dev/null || true)"
  if [ -z "${INSTALLED_VERSION}" ]; then
    log_error "dotnet is on PATH but 'dotnet --version' returned nothing. Is the SDK installed correctly?"
    exit 3
  fi

  log_verbose "Found dotnet ${INSTALLED_VERSION}"

  # Validate major version matches requested SDK_VERSION (compare major.minor)
  REQUESTED_MAJOR="$(printf '%s' "${SDK_VERSION}" | cut -d. -f1)"
  INSTALLED_MAJOR="$(printf '%s' "${INSTALLED_VERSION}" | cut -d. -f1)"

  if [ "${INSTALLED_MAJOR}" -lt "${REQUESTED_MAJOR}" ]; then
    log_error "Installed dotnet version ${INSTALLED_VERSION} is older than required ${SDK_VERSION}."
    log_error "Install .NET SDK ${SDK_VERSION}+ from https://dotnet.microsoft.com/download"
    exit 3
  fi

  # If the installed SDK major is newer than requested, use the installed major.
  # This ensures TargetFramework matches the available runtime (e.g. sdk 10 -> net10.0).
  if [ "${INSTALLED_MAJOR}" -gt "${REQUESTED_MAJOR}" ]; then
    log_verbose "SDK ${INSTALLED_VERSION} is newer than requested ${SDK_VERSION}; using ${INSTALLED_MAJOR}.0 as target framework."
    SDK_VERSION="${INSTALLED_MAJOR}.0"
    export SDK_VERSION
  fi

  log_info "Prerequisites OK (dotnet ${INSTALLED_VERSION})"
}
