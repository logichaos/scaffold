#!/bin/sh
# scaffold/tests/test_invalid_args.sh — Verify invalid argument handling
# Exit code 1: general error
# Exit code 2: invalid arguments (missing required, unknown flag, invalid name)

set -eu

SCAFFOLD_SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/scripts/bootstrap.sh"

pass() { printf '[PASS] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; exit 1; }

run() {
  # Run bootstrap with given args; capture exit code without aborting on failure
  sh "${SCAFFOLD_SCRIPT}" "$@" >/dev/null 2>&1 || true
  # Re-run to capture exit code (pipefail-safe)
  sh "${SCAFFOLD_SCRIPT}" "$@" >/dev/null 2>&1
  echo $?
}

get_exit() {
  sh "${SCAFFOLD_SCRIPT}" "$@" >/dev/null 2>&1
  echo $?
}

echo "--- test_invalid_args.sh ---"

# 1. No arguments → exit 2
sh "${SCAFFOLD_SCRIPT}" >/dev/null 2>&1 || ACTUAL=$?
ACTUAL="${ACTUAL:-0}"
if [ "${ACTUAL}" -eq 2 ]; then
  pass "exit 2 with no arguments"
else
  fail "expected exit 2 with no arguments, got ${ACTUAL}"
fi

# 2. Unknown flag → exit 2
ACTUAL=0
sh "${SCAFFOLD_SCRIPT}" --name Foo --output /tmp/noop --unknown-flag >/dev/null 2>&1 || ACTUAL=$?
if [ "${ACTUAL}" -eq 2 ]; then
  pass "exit 2 for unknown flag"
else
  fail "expected exit 2 for unknown flag, got ${ACTUAL}"
fi

# 3. Solution name with spaces → exit 2
ACTUAL=0
sh "${SCAFFOLD_SCRIPT}" --name "My Solution" --output /tmp/noop >/dev/null 2>&1 || ACTUAL=$?
if [ "${ACTUAL}" -eq 2 ]; then
  pass "exit 2 for solution name with spaces"
else
  fail "expected exit 2 for name with spaces, got ${ACTUAL}"
fi

# 4. Solution name with special chars → exit 2
ACTUAL=0
sh "${SCAFFOLD_SCRIPT}" --name "foo@bar" --output /tmp/noop >/dev/null 2>&1 || ACTUAL=$?
if [ "${ACTUAL}" -eq 2 ]; then
  pass "exit 2 for solution name with special characters"
else
  fail "expected exit 2 for name with special chars, got ${ACTUAL}"
fi

# 5. Missing --name value (flag without argument) → non-zero
ACTUAL=0
sh "${SCAFFOLD_SCRIPT}" --name --output /tmp/noop >/dev/null 2>&1 || ACTUAL=$?
if [ "${ACTUAL}" -ne 0 ]; then
  pass "non-zero exit when --name has no value"
else
  fail "expected non-zero exit when --name is missing value, got 0"
fi

# 6. --help exits 0 and prints usage
ACTUAL=0
OUTPUT="$(sh "${SCAFFOLD_SCRIPT}" --help 2>&1)" || ACTUAL=$?
if [ "${ACTUAL}" -eq 0 ] && echo "${OUTPUT}" | grep -q "Usage:"; then
  pass "exit 0 and Usage printed for --help"
else
  fail "expected exit 0 and Usage output for --help, got exit ${ACTUAL}"
fi

echo "--- Invalid argument tests passed ---"
