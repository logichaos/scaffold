#!/bin/sh
# scaffold/scripts/lib/benchmarks.sh — Generate optional BenchmarkDotNet project

TMPL_DIR="${TMPL_DIR:-"${SCRIPT_DIR}/../templates"}"

generate_benchmarks() {
  log_info "Generating BenchmarkDotNet scaffolding..."

  BENCH_DIR="${OUTPUT_DIR}/tests/Benchmarks"
  mkdir -p "${BENCH_DIR}"

  # Benchmarks.csproj
  sed -e "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
      -e "s/{{TARGET_FRAMEWORK}}/${TARGET_FRAMEWORK}/g" \
      "${TMPL_DIR}/Benchmarks.csproj.tmpl" \
      > "${BENCH_DIR}/${SOLUTION_NAME}.Benchmarks.csproj"
  log_verbose "Generated: ${BENCH_DIR}/${SOLUTION_NAME}.Benchmarks.csproj"

  # Program.cs — BenchmarkDotNet entry point (top-level statements)
  printf 'using BenchmarkDotNet.Running;\nusing %s.Benchmarks;\n\n// Run with: dotnet run -c Release --project tests/Benchmarks/\nBenchmarkRunner.Run<SampleBenchmark>();\n' "${SOLUTION_NAME}" \
    > "${BENCH_DIR}/Program.cs"
  log_verbose "Generated: ${BENCH_DIR}/Program.cs"

  # SampleBenchmark.cs
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/SampleBenchmark.cs.tmpl" \
    > "${BENCH_DIR}/SampleBenchmark.cs"
  log_verbose "Generated: ${BENCH_DIR}/SampleBenchmark.cs"

  # ci-perf.yml GitHub Actions workflow
  GH_WORKFLOWS="${OUTPUT_DIR}/.github/workflows"
  mkdir -p "${GH_WORKFLOWS}"
  sed "s/{{SOLUTION_NAME}}/${SOLUTION_NAME}/g" \
    "${TMPL_DIR}/ci-perf.yml.tmpl" \
    > "${GH_WORKFLOWS}/ci-perf.yml"
  log_verbose "Generated: ${GH_WORKFLOWS}/ci-perf.yml"

  # Add benchmark project to solution
  _sln="${SLN_FILE:-}"
  if [ -z "${_sln}" ]; then
    if [ -f "${OUTPUT_DIR}/${SOLUTION_NAME}.sln" ]; then
      _sln="${OUTPUT_DIR}/${SOLUTION_NAME}.sln"
    elif [ -f "${OUTPUT_DIR}/${SOLUTION_NAME}.slnx" ]; then
      _sln="${OUTPUT_DIR}/${SOLUTION_NAME}.slnx"
    fi
  fi
  if [ -n "${_sln}" ]; then
    dotnet sln "${_sln}" \
      add "${BENCH_DIR}/${SOLUTION_NAME}.Benchmarks.csproj" \
      2>/dev/null || log_verbose "Warning: could not add Benchmarks project to solution (dotnet sln add failed)"
  fi

  log_info "BenchmarkDotNet scaffolding generated. Run: make benchmark"
}
