#!/usr/bin/env pwsh
# Regenerate codegen output (freezed / json_serializable / retrofit).
# Pass --watch (or other build_runner flags) to switch modes.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

if ($args.Count -gt 0 -and $args[0] -eq '--watch') {
    fvm dart run build_runner watch --delete-conflicting-outputs @($args | Select-Object -Skip 1)
} else {
    fvm dart run build_runner build --delete-conflicting-outputs @args
}
