#!/usr/bin/env pwsh
# Run the app in profile mode (perf profiling) against the prod environment.
# Override env or add flags by passing through, e.g. ... --dart-define=ENV=dev
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

fvm flutter run --profile --dart-define=ENV=prod @args
