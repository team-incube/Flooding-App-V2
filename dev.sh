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
    # env files are gitignored. Pull real values from GitHub Actions variables
    # (ENV_DEV / ENV_PROD) via gh; fall back to the .env.example template.
    # `setup --force` (-f) re-fetches and overwrites existing .env.* from gh.
    force=false
    for a in "$@"; do
      [ "$a" = "--force" ] || [ "$a" = "-f" ] && force=true
    done
    for f in .env.dev .env.prod; do
      exists=false; [ -f "$f" ] && exists=true
      [ "$exists" = true ] && [ "$force" = false ] && continue
      case "$f" in
        .env.dev)  var=ENV_DEV ;;
        .env.prod) var=ENV_PROD ;;
      esac
      tmp="$f.tmp.$$"
      if command -v gh &> /dev/null && gh variable get "$var" > "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
        mv "$tmp" "$f"
        [ "$exists" = true ] && echo "Updated $f from GitHub variable $var" || echo "Created $f from GitHub variable $var"
      else
        rm -f "$tmp"
        # Never clobber an existing file with the template on a failed fetch.
        if [ "$exists" = true ]; then
          echo "⚠️  Could not refresh $f from gh; kept the existing file."
        elif [ -f .env.example ]; then
          cp .env.example "$f"
          echo "Created $f from .env.example (gh unavailable; fill in real values)"
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
