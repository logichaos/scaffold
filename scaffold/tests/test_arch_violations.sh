#!/bin/sh
# scaffold/tests/test_arch_violations.sh — Verify architecture tests catch dependency violations

set -eu

SCAFFOLD_SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/scripts/bootstrap.sh"
TEST_DIR="/tmp/test-scaffold-arch-$$"
SOLUTION_NAME="TestArchViolations"

cleanup() { rm -rf "${TEST_DIR}"; }
trap cleanup EXIT

pass() { printf '[PASS] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; exit 1; }

echo "--- test_arch_violations.sh ---"

# 1. Scaffold a fresh solution
sh "${SCAFFOLD_SCRIPT}" --name "${SOLUTION_NAME}" --output "${TEST_DIR}" || \
  fail "bootstrap.sh failed"
pass "bootstrap.sh succeeded"

# 2. Verify make test passes on clean scaffold
(cd "${TEST_DIR}" && make build && make test) || fail "Initial make test failed on clean scaffold"
pass "make test passes on clean scaffold"

# 3. Inject a Presentation -> Infrastructure violation
#    (Presentation must NOT depend on Infrastructure directly per Clean Architecture)
#    Presentation currently only refs Application; Infrastructure refs Application+Domain.
#    Adding Presentation->Infrastructure does NOT create a circular build dependency.
VIOLATION_FILE="${TEST_DIR}/src/Presentation/InfrastructureViolation.cs"
cat > "${VIOLATION_FILE}" <<CSEOF
// This file intentionally violates architecture rules for testing purposes
namespace ${SOLUTION_NAME}.Presentation;

// Intentional violation: Presentation class referencing Infrastructure directly.
// ArchUnitNET will detect this outbound dependency on Infrastructure.
internal class BadPresentationClass
{
    private static readonly System.Type _marker = typeof(${SOLUTION_NAME}.Infrastructure.AssemblyMarker);
}
CSEOF

# Add Infrastructure ref to Presentation.csproj so the code compiles
PRES_CSPROJ="${TEST_DIR}/src/Presentation/${SOLUTION_NAME}.Presentation.csproj"
sed -i 's|</Project>|  <ItemGroup>\n    <ProjectReference Include="../Infrastructure/'"${SOLUTION_NAME}"'.Infrastructure.csproj" />\n  </ItemGroup>\n</Project>|' \
  "${PRES_CSPROJ}"

pass "Presentation->Infrastructure violation injected"

# 4. Rebuild with violation (must succeed at build level, fail at test level)
(cd "${TEST_DIR}" && make build) || fail "Build failed after injecting violation (expected build to succeed)"
pass "Build succeeded with violation present (expected)"

# 5. Run tests — architecture tests must fail with identifying message
ARCH_OUTPUT="$(cd "${TEST_DIR}" && make test 2>&1 || true)"
if echo "${ARCH_OUTPUT}" | grep -qi "domain.*infrastructure\|architecture\|violation\|dependency"; then
  pass "Architecture tests failed with identifying message (expected)"
else
  printf '[OUTPUT]\n%s\n' "${ARCH_OUTPUT}"
  fail "Architecture tests did not produce identifying violation message"
fi

# 6. Confirm non-zero exit
if (cd "${TEST_DIR}" && make test >/dev/null 2>&1); then
  fail "make test should have returned non-zero with violation"
fi
pass "make test returned non-zero exit for architecture violation"

echo "--- Architecture violation tests passed ---"
