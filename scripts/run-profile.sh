#!/usr/bin/env bash
# Run the app in profile mode (perf profiling) against the prod environment.
# Override env or add flags by passing through, e.g. ... --dart-define=ENV=dev
set -euo pipefail
cd "$(dirname "$0")/.."

fvm flutter run --profile --dart-define=ENV=prod "$@"
