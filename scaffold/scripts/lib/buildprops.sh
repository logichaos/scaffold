#!/bin/sh
# scaffold/scripts/lib/buildprops.sh — Generate Directory.Build.props, Directory.Packages.props, .globalconfig

TMPL_DIR="${TMPL_DIR:-"${SCRIPT_DIR}/../templates"}"

generate_buildprops() {
  log_info "Generating build property files..."

  # Directory.Build.props — applies to all projects
  cp "${TMPL_DIR}/Directory.Build.props.tmpl" "${OUTPUT_DIR}/Directory.Build.props"
  log_verbose "Generated: ${OUTPUT_DIR}/Directory.Build.props"

  # Directory.Packages.props — centrally manages NuGet package versions
  cp "${TMPL_DIR}/Directory.Packages.props.tmpl" "${OUTPUT_DIR}/Directory.Packages.props"
  log_verbose "Generated: ${OUTPUT_DIR}/Directory.Packages.props"

  # .globalconfig — EditorConfig-style code style rules for all projects
  cp "${TMPL_DIR}/.globalconfig.tmpl" "${OUTPUT_DIR}/.globalconfig"
  log_verbose "Generated: ${OUTPUT_DIR}/.globalconfig"

  # global.json — pins SDK and enables Microsoft.Testing.Platform mode for dotnet test
  cat > "${OUTPUT_DIR}/global.json" <<'GLOBALJSON'
{
  "sdk": {
    "rollForward": "latestMinor"
  },
  "test": {
    "runner": "Microsoft.Testing.Platform"
  }
}
GLOBALJSON
  log_verbose "Generated: ${OUTPUT_DIR}/global.json"

  log_info "Build property files generated."
}
