#!/bin/sh
# scaffold/scripts/lib/log.sh — Logging helpers
# Exports: log_info, log_warn, log_error

log_info() {
  printf '[INFO]  %s\n' "$*"
}

log_warn() {
  printf '[WARN]  %s\n' "$*" >&2
}

log_error() {
  printf '[ERROR] %s\n' "$*" >&2
}

log_verbose() {
  if [ "${VERBOSE:-false}" = "true" ]; then
    printf '[DEBUG] %s\n' "$*"
  fi
}
