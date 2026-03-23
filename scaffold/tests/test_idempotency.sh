#!/bin/sh
# scaffold/tests/test_idempotency.sh — Verify idempotency: double-run exits 4; --force overwrites cleanly
# Exit code 4: target directory not empty (without --force)

set -eu

SCAFFOLD_SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/scripts/bootstrap.sh"
TEST_DIR="/tmp/test-scaffold-idempotency-$$"
SOLUTION_NAME="TestIdempotency"

cleanup() { rm -rf "${TEST_DIR}"; }
trap cleanup EXIT

pass() { printf '[PASS] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; exit 1; }

echo "--- test_idempotency.sh ---"

# 1. First run must succeed
sh "${SCAFFOLD_SCRIPT}" --name "${SOLUTION_NAME}" --output "${TEST_DIR}" || \
  fail "First bootstrap.sh run failed"
pass "First run succeeded"

# 2. Second run without --force must exit 4
ACTUAL=0
sh "${SCAFFOLD_SCRIPT}" --name "${SOLUTION_NAME}" --output "${TEST_DIR}" >/dev/null 2>&1 || ACTUAL=$?
if [ "${ACTUAL}" -eq 4 ]; then
  pass "exit 4 on double-run without --force"
else
  fail "expected exit 4 on double-run without --force, got ${ACTUAL}"
fi

# 3. Second run with --force must succeed (exit 0)
sh "${SCAFFOLD_SCRIPT}" --name "${SOLUTION_NAME}" --output "${TEST_DIR}" --force || \
  fail "--force run failed (expected exit 0)"
pass "--force run succeeded (exit 0)"

# 4. Verify output is still a valid scaffold after --force re-run
{ [ -f "${TEST_DIR}/${SOLUTION_NAME}.sln" ] || [ -f "${TEST_DIR}/${SOLUTION_NAME}.slnx" ]; } || \
  fail "Solution file missing after --force re-run"
[ -f "${TEST_DIR}/Makefile" ]            || fail "Makefile missing after --force re-run"
[ -d "${TEST_DIR}/src/Domain" ]          || fail "src/Domain missing after --force re-run"
[ -d "${TEST_DIR}/src/Application" ]     || fail "src/Application missing after --force re-run"
[ -d "${TEST_DIR}/src/Infrastructure" ]  || fail "src/Infrastructure missing after --force re-run"
[ -d "${TEST_DIR}/src/Presentation" ]    || fail "src/Presentation missing after --force re-run"
[ -d "${TEST_DIR}/tests" ]               || fail "tests/ missing after --force re-run"
pass "All expected files/dirs present after --force re-run"

# 5. Verify re-run builds cleanly
(cd "${TEST_DIR}" && make build) || fail "make build failed after --force re-run"
pass "make build succeeds after --force re-run"

echo "--- Idempotency tests passed ---"
