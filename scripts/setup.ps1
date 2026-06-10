#!/usr/bin/env pwsh
# Prepare the project after clone: pin Flutter via FVM, fetch deps, generate code.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

fvm install                      # reads .fvmrc, downloads the pinned Flutter SDK
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs

foreach ($f in @('.env.dev', '.env.prod')) {
    if (-not (Test-Path $f)) {
        Write-Warning "$f missing — copy .env.example to it and fill in real values."
    }
}
