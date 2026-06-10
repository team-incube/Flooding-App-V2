#!/usr/bin/env bash
# Regenerate codegen output (freezed / json_serializable / retrofit).
# Pass --watch (or other build_runner flags) to switch modes.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ "${1:-}" = "--watch" ]; then
  shift
  fvm dart run build_runner watch --delete-conflicting-outputs "$@"
else
  fvm dart run build_runner build --delete-conflicting-outputs "$@"
fi
