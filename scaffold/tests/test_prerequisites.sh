#!/bin/sh
# scaffold/tests/test_prerequisites.sh — Verify prerequisite checks work correctly
# Exit code 3: dotnet SDK not found

set -eu

SCAFFOLD_SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/scripts/bootstrap.sh"

pass() { printf '[PASS] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; exit 1; }

echo "--- test_prerequisites.sh ---"

# 1. Verify dotnet is available in this environment (prerequisite for other tests)
if ! command -v dotnet >/dev/null 2>&1; then
  echo "[SKIP] dotnet SDK not found — skipping prerequisite tests"
  exit 0
fi
pass "dotnet SDK present in PATH"

# 2. Verify bootstrap exits 2 when --name is missing
ACTUAL=0
sh "${SCAFFOLD_SCRIPT}" --output /tmp/noop >/dev/null 2>&1 || ACTUAL=$?
if [ "${ACTUAL}" -eq 2 ]; then
  pass "exit 2 when --name is missing"
else
  fail "expected exit 2 when --name missing, got ${ACTUAL}"
fi

# 3. Verify bootstrap exits 2 when --output is missing
ACTUAL=0
sh "${SCAFFOLD_SCRIPT}" --name TestPrereqs >/dev/null 2>&1 || ACTUAL=$?
if [ "${ACTUAL}" -eq 2 ]; then
  pass "exit 2 when --output is missing"
else
  fail "expected exit 2 when --output missing, got ${ACTUAL}"
fi

# 4. Simulate missing dotnet by overriding PATH (exit code 3)
FAKE_PATH="/tmp/fake-no-dotnet-$$"
mkdir -p "${FAKE_PATH}"
OLD_PATH="${PATH}"
SH_BIN="$(command -v sh)"  # capture full path before overriding PATH
export PATH="${FAKE_PATH}"
ACTUAL=0
"${SH_BIN}" "${SCAFFOLD_SCRIPT}" --name TestMissingSdk --output /tmp/missing-sdk >/dev/null 2>&1 || ACTUAL=$?
export PATH="${OLD_PATH}"
rm -rf "${FAKE_PATH}"
if [ "${ACTUAL}" -eq 3 ]; then
  pass "exit 3 when dotnet SDK not found"
else
  fail "expected exit 3 when dotnet missing, got ${ACTUAL}"
fi

echo "--- Prerequisite tests passed ---"
