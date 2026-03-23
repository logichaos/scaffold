#!/bin/sh
# scaffold/scripts/lib/observability.sh — Generate OpenTelemetry/Prometheus/Grafana scaffolding

TMPL_DIR="${TMPL_DIR:-"${SCRIPT_DIR}/../templates"}"

generate_observability() {
  log_info "Generating observability scaffolding..."

  PRES_DIR="${OUTPUT_DIR}/src/Presentation"
  DOCS_DIR="${OUTPUT_DIR}/docs/dashboards"
  GH_WORKFLOWS="${OUTPUT_DIR}/.github/workflows"
  mkdir -p "${DOCS_DIR}"
  mkdir -p "${GH_WORKFLOWS}"

  # OtelSetup.cs — OpenTelemetry wiring extension
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/otel-setup.cs.tmpl" \
    > "${PRES_DIR}/OtelSetup.cs"
  log_verbose "Generated: ${PRES_DIR}/OtelSetup.cs"

  # PrometheusEndpoint.cs — /metrics endpoint
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/prometheus-endpoint.cs.tmpl" \
    > "${PRES_DIR}/PrometheusEndpoint.cs"
  log_verbose "Generated: ${PRES_DIR}/PrometheusEndpoint.cs"

  # Grafana dashboard JSON template
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/grafana-dashboard.json.tmpl" \
    > "${DOCS_DIR}/app-dashboard.json"
  log_verbose "Generated: ${DOCS_DIR}/app-dashboard.json"

  # ci-observability.yml GitHub Actions workflow
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/ci-observability.yml.tmpl" \
    > "${GH_WORKFLOWS}/ci-observability.yml"
  log_verbose "Generated: ${GH_WORKFLOWS}/ci-observability.yml"

  # Patch Presentation.csproj to add observability package references
  PRES_CSPROJ="${PRES_DIR}/${SOLUTION_NAME}.Presentation.csproj"
  if [ -f "${PRES_CSPROJ}" ]; then
    sed -i 's|</Project>|  <ItemGroup>\n    <!-- Observability: OpenTelemetry + Prometheus -->\n    <PackageReference Include="OpenTelemetry.Extensions.Hosting" />\n    <PackageReference Include="OpenTelemetry.Instrumentation.AspNetCore" />\n    <PackageReference Include="OpenTelemetry.Instrumentation.Http" />\n    <PackageReference Include="OpenTelemetry.Instrumentation.Runtime" />\n    <PackageReference Include="OpenTelemetry.Exporter.OpenTelemetryProtocol" />\n    <PackageReference Include="prometheus-net.AspNetCore" />\n  </ItemGroup>\n</Project>|' "${PRES_CSPROJ}"
    log_verbose "Patched: ${PRES_CSPROJ} with observability package references"
  fi

  log_info "Observability scaffolding generated."
}
