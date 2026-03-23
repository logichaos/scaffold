#!/bin/sh
# scaffold/scripts/lib/solution.sh — Create .sln file and add all projects

generate_solution() {
  log_info "Creating solution file..."

  # Create solution — dotnet 10+ produces .slnx by default; use --sln-format sln for backwards compat
  dotnet new sln --name "${SOLUTION_NAME}" --output "${OUTPUT_DIR}" --force 2>/dev/null || \
    dotnet new sln --name "${SOLUTION_NAME}" --output "${OUTPUT_DIR}"

  # Locate the created solution file (handles both .sln and .slnx)
  SLN_FILE=""
  if [ -f "${OUTPUT_DIR}/${SOLUTION_NAME}.sln" ]; then
    SLN_FILE="${OUTPUT_DIR}/${SOLUTION_NAME}.sln"
  elif [ -f "${OUTPUT_DIR}/${SOLUTION_NAME}.slnx" ]; then
    SLN_FILE="${OUTPUT_DIR}/${SOLUTION_NAME}.slnx"
  fi
  if [ -z "${SLN_FILE}" ]; then
    log_error "Could not locate solution file after creation in ${OUTPUT_DIR}"
    exit 1
  fi

  log_verbose "Created ${SLN_FILE}"

  # Add all projects in correct order (src first, then tests)
  dotnet sln "${SLN_FILE}" add \
    "${OUTPUT_DIR}/src/Domain/${SOLUTION_NAME}.Domain.csproj" \
    "${OUTPUT_DIR}/src/Application/${SOLUTION_NAME}.Application.csproj" \
    "${OUTPUT_DIR}/src/Infrastructure/${SOLUTION_NAME}.Infrastructure.csproj" \
    "${OUTPUT_DIR}/src/Presentation/${SOLUTION_NAME}.Presentation.csproj" \
    "${OUTPUT_DIR}/tests/Domain.Tests/${SOLUTION_NAME}.Domain.Tests.csproj" \
    "${OUTPUT_DIR}/tests/Application.Tests/${SOLUTION_NAME}.Application.Tests.csproj" \
    "${OUTPUT_DIR}/tests/Architecture.Tests/${SOLUTION_NAME}.Architecture.Tests.csproj"

  # Export SLN_FILE so other scripts (e.g. benchmarks.sh) can use it
  export SLN_FILE

  log_info "Solution file created: ${SLN_FILE}"
}
