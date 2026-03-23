#!/bin/sh
# scaffold/tests/test_makefile_targets.sh — Integration test: validates all Makefile targets on a fresh scaffold

set -euo pipefail

SCAFFOLD_SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/scripts/bootstrap.sh"
TEST_DIR="/tmp/test-scaffold-makefile-$$"
SOLUTION_NAME="TestMakefileTargets"

cleanup() {
  rm -rf "${TEST_DIR}"
}
trap cleanup EXIT

pass() { printf '[PASS] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; exit 1; }

echo "--- test_makefile_targets.sh ---"

# 1. Scaffold a fresh solution
sh "${SCAFFOLD_SCRIPT}" --name "${SOLUTION_NAME}" --output "${TEST_DIR}" || fail "bootstrap.sh failed"
pass "bootstrap.sh succeeded"

# 2. build target
(cd "${TEST_DIR}" && make build) || fail "make build failed"
pass "make build"

# 3. test target
(cd "${TEST_DIR}" && make test) || fail "make test failed"
pass "make test"

# 4. lint target
(cd "${TEST_DIR}" && make lint) || fail "make lint failed"
pass "make lint"

# 5. clean target
(cd "${TEST_DIR}" && make clean) || fail "make clean failed"
# Verify artifacts removed
if find "${TEST_DIR}" -type d -name bin | grep -q bin 2>/dev/null; then
  fail "make clean: bin/ directories still present"
fi
pass "make clean"

# 6. coverage target (no tests yet — should emit clear error and non-zero exit)
if (cd "${TEST_DIR}" && make coverage 2>&1 | grep -q "no tests found"); then
  pass "make coverage: empty test suite handled gracefully"
elif (cd "${TEST_DIR}" && make coverage); then
  fail "make coverage: should have failed with 0% coverage"
else
  pass "make coverage: failed non-zero as expected for 0% coverage"
fi

echo "--- All Makefile target tests passed ---"
