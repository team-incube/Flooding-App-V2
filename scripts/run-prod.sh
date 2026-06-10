#!/usr/bin/env bash
# Run the app against the prod environment (--dart-define=ENV=prod).
# Extra flags pass through, e.g. ./scripts/run-prod.sh -d emulator-5554
set -euo pipefail
cd "$(dirname "$0")/.."

fvm flutter run --dart-define=ENV=prod "$@"
