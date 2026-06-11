#!/usr/bin/env pwsh
# Dev task runner. Usage: .\dev.ps1 <setup|dev|prod|profile|gen> [extra args]
#   setup    fvm install + pub get + build_runner (also seeds .env.* from .env.example)
#   dev      run dev flavor       (--flavor dev   -> loads .env.dev)
#   prod     run prod flavor      (--flavor prod  -> loads .env.prod)
#   profile  run prod in profile  (--profile --flavor prod)
#   gen      build_runner build    (`.\dev.ps1 gen --watch` to watch)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (-not (Get-Command fvm -ErrorAction SilentlyContinue)) {
    Write-Error 'fvm is not installed. Install FVM first: https://fvm.app'
    exit 1
}

$cmd = if ($args.Count -gt 0) { $args[0] } else { '' }
$rest = if ($args.Count -gt 1) { $args[1..($args.Count - 1)] } else { @() }

switch ($cmd) {
    'setup' {
        foreach ($f in @('.env.dev', '.env.prod')) {
            if (-not (Test-Path $f)) {
                if (Test-Path '.env.example') {
                    Copy-Item '.env.example' $f
                    Write-Host "Created $f from .env.example"
                } else {
                    Write-Warning "$f is missing and .env.example was not found."
                }
            }
        }
        fvm install
        fvm flutter pub get
        fvm dart run build_runner build --delete-conflicting-outputs
    }
    'dev'     { fvm flutter run --flavor dev @rest }
    'prod'    { fvm flutter run --flavor prod @rest }
    'profile' { fvm flutter run --profile --flavor prod @rest }
    'gen' {
        if ($rest.Count -gt 0 -and $rest[0] -eq '--watch') {
            $watchArgs = if ($rest.Count -gt 1) { $rest[1..($rest.Count - 1)] } else { @() }
            fvm dart run build_runner watch --delete-conflicting-outputs @watchArgs
        } else {
            fvm dart run build_runner build --delete-conflicting-outputs @rest
        }
    }
    default {
        Write-Host 'Usage: .\dev.ps1 <setup|dev|prod|profile|gen> [args]'
        Write-Host '  setup    fvm install + pub get + build_runner (seeds .env.* from .env.example)'
        Write-Host '  dev      run with --flavor dev'
        Write-Host '  prod     run with --flavor prod'
        Write-Host '  profile  run with --profile --flavor prod'
        Write-Host '  gen      build_runner build (gen --watch to watch)'
        if ($cmd) { exit 1 }
    }
}
