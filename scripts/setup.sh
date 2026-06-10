#!/usr/bin/env bash
# Prepare the project after clone: pin Flutter via FVM, fetch deps, generate code.
set -euo pipefail
cd "$(dirname "$0")/.."

fvm install                      # reads .fvmrc, downloads the pinned Flutter SDK
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs

for f in .env.dev .env.prod; do
  [ -f "$f" ] || echo "⚠️  $f missing — copy .env.example to it and fill in real values."
done
