#!/usr/bin/env pwsh
# Run the app against the prod environment (--dart-define=ENV=prod).
# Extra flags pass through, e.g. ./scripts/run-prod.ps1 -d emulator-5554
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

fvm flutter run --dart-define=ENV=prod @args
