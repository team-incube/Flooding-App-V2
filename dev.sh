#!/usr/bin/env bash
# Dev task runner. Usage: ./dev.sh <setup|prod|profile|gen> [extra args]
#   setup    fvm install + pub get + build_runner (also seeds .env.* from .env.example)
#   prod     run against prod env  (--dart-define=ENV=prod)
#   profile  run in profile mode   (--profile --dart-define=ENV=prod)
#   gen      build_runner build    (./dev.sh gen --watch to watch)
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v fvm &> /dev/null; then
  echo "❌ fvm is not installed. Install FVM first: https://fvm.app"
  exit 1
fi

cmd="${1:-}"
[ "$#" -gt 0 ] && shift || true

case "$cmd" in
  setup)
    for f in .env.dev .env.prod; do
      if [ ! -f "$f" ]; then
        if [ -f .env.example ]; then
          cp .env.example "$f"
          echo "Created $f from .env.example"
        else
          echo "⚠️  $f is missing and .env.example was not found."
        fi
      fi
    done
    fvm install
    fvm flutter pub get
    fvm dart run build_runner build --delete-conflicting-outputs
    ;;
  prod)    fvm flutter run --dart-define=ENV=prod "$@" ;;
  profile) fvm flutter run --profile --dart-define=ENV=prod "$@" ;;
  gen)
    if [ "${1:-}" = "--watch" ]; then
      shift
      fvm dart run build_runner watch --delete-conflicting-outputs "$@"
    else
      fvm dart run build_runner build --delete-conflicting-outputs "$@"
    fi
    ;;
  *)
    echo "Usage: ./dev.sh <setup|prod|profile|gen> [args]"
    echo "  setup    fvm install + pub get + build_runner (seeds .env.* from .env.example)"
    echo "  prod     run with --dart-define=ENV=prod"
    echo "  profile  run with --profile --dart-define=ENV=prod"
    echo "  gen      build_runner build (gen --watch to watch)"
    [ -n "$cmd" ] && exit 1 || exit 0
    ;;
esac
