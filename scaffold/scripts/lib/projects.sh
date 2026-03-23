#!/bin/sh
# scaffold/scripts/lib/projects.sh — Generate .csproj files from templates

TMPL_DIR="${TMPL_DIR:-"${SCRIPT_DIR}/../templates"}"

# Substitute {{SOLUTION_NAME}} and {{TARGET_FRAMEWORK}} in a template file and write to destination
render_template() {
  tmpl_file="$1"
  dest_file="$2"
  # Derive target framework here so it reflects any runtime SDK_VERSION update from prereqs.sh
  _tf="net${SDK_VERSION}"
  mkdir -p "${dest_file%/*}"
  sed -e "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
      -e "s/{{TARGET_FRAMEWORK}}/${_tf}/g" \
      "${tmpl_file}" > "${dest_file}"
  log_verbose "Generated: ${dest_file}"
}

generate_projects() {
  log_info "Generating project files..."
  # Export TARGET_FRAMEWORK so other lib scripts (benchmarks.sh) can use it
  TARGET_FRAMEWORK="net${SDK_VERSION}"
  export TARGET_FRAMEWORK

  SRC="${OUTPUT_DIR}/src"
  TST="${OUTPUT_DIR}/tests"

  # Production projects
  render_template "${TMPL_DIR}/Domain.csproj.tmpl" \
    "${SRC}/Domain/${SOLUTION_NAME}.Domain.csproj"

  render_template "${TMPL_DIR}/Application.csproj.tmpl" \
    "${SRC}/Application/${SOLUTION_NAME}.Application.csproj"

  render_template "${TMPL_DIR}/Infrastructure.csproj.tmpl" \
    "${SRC}/Infrastructure/${SOLUTION_NAME}.Infrastructure.csproj"

  render_template "${TMPL_DIR}/Presentation.csproj.tmpl" \
    "${SRC}/Presentation/${SOLUTION_NAME}.Presentation.csproj"

  # Test projects
  render_template "${TMPL_DIR}/Domain.Tests.csproj.tmpl" \
    "${TST}/Domain.Tests/${SOLUTION_NAME}.Domain.Tests.csproj"

  render_template "${TMPL_DIR}/Application.Tests.csproj.tmpl" \
    "${TST}/Application.Tests/${SOLUTION_NAME}.Application.Tests.csproj"

  render_template "${TMPL_DIR}/Architecture.Tests.csproj.tmpl" \
    "${TST}/Architecture.Tests/${SOLUTION_NAME}.Architecture.Tests.csproj"

  # Placeholder source files
  cat > "${SRC}/Domain/README.md" <<MDEOF
# ${SOLUTION_NAME}.Domain

Contains domain entities, value objects, aggregates, and domain events.

## Rules
- No third-party framework references
- Aggregates enforce their own consistency boundaries
- Value objects are immutable and compared by value
MDEOF

  mkdir -p "${SRC}/Application/Features"
  touch "${SRC}/Application/Features/.gitkeep"

  cat > "${SRC}/Application/README.md" <<MDEOF
# ${SOLUTION_NAME}.Application

Contains use case handlers, application service interfaces, DTOs, and repository/port interfaces.
Organise by feature: \`Features/<FeatureName>/<Command|Query>.cs\`
MDEOF

  cat > "${SRC}/Infrastructure/README.md" <<MDEOF
# ${SOLUTION_NAME}.Infrastructure

Implements ports defined in Application: repositories, external service clients, EF Core DbContext.
MDEOF

  cat > "${SRC}/Presentation/Program.cs" <<CSEOF
var builder = WebApplication.CreateBuilder(args);

// Register Mediator (source-generated, zero-allocation)
builder.Services.AddMediator();

// Register FluentValidation pipeline behaviours here

var app = builder.Build();

app.MapGet("/", () => "Hello from ${SOLUTION_NAME}!");

app.Run();
CSEOF

  log_info "Project files generated."
}
