#!/usr/bin/env pwsh
# Dev task runner. Usage: .\dev.ps1 <setup|prod|profile|gen> [extra args]
#   setup    fvm install + pub get + build_runner (also seeds .env.* from .env.example)
#   prod     run against prod env  (--dart-define=ENV=prod)
#   profile  run in profile mode   (--profile --dart-define=ENV=prod)
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
        # env files are gitignored. Pull real values from GitHub Actions variables
        # (ENV_DEV / ENV_PROD) via gh; fall back to the .env.example template.
        # `setup --force` (-f) re-fetches and overwrites existing .env.* from gh.
        $force = ($rest -contains '--force') -or ($rest -contains '-f')
        $hasGh = [bool](Get-Command gh -ErrorAction SilentlyContinue)
        $envMap = @{ '.env.dev' = 'ENV_DEV'; '.env.prod' = 'ENV_PROD' }
        foreach ($f in @('.env.dev', '.env.prod')) {
            $exists = Test-Path $f
            if ($exists -and -not $force) { continue }
            $fetched = $false
            if ($hasGh) {
                # gh emits one line per env entry; PowerShell captures them as a
                # string array, and Set-Content writes each element on its own line.
                $value = gh variable get $envMap[$f] 2>$null
                if ($LASTEXITCODE -eq 0 -and $value) {
                    # WriteAllLines writes UTF-8 without BOM; Set-Content -Encoding utf8
                    # on Windows PowerShell 5.1 prepends a BOM that corrupts the first
                    # env key (﻿API_BASE_URL), breaking dotenv parsing.
                    [System.IO.File]::WriteAllLines((Join-Path (Get-Location) $f), [string[]]$value)
                    $verb = if ($exists) { 'Updated' } else { 'Created' }
                    Write-Host "$verb $f from GitHub variable $($envMap[$f])"
                    $fetched = $true
                }
            }
            if (-not $fetched) {
                # Never clobber an existing file with the template on a failed fetch.
                if ($exists) {
                    Write-Warning "Could not refresh $f from gh; kept the existing file."
                } elseif (Test-Path '.env.example') {
                    Copy-Item '.env.example' $f
                    Write-Host "Created $f from .env.example (gh unavailable; fill in real values)"
                } else {
                    Write-Warning "$f is missing and .env.example was not found."
                }
            }
        }
        fvm install
        fvm flutter pub get
        fvm dart run build_runner build --delete-conflicting-outputs
    }
    'prod'    { fvm flutter run --dart-define=ENV=prod @rest }
    'profile' { fvm flutter run --profile --dart-define=ENV=prod @rest }
    'gen' {
        if ($rest.Count -gt 0 -and $rest[0] -eq '--watch') {
            $watchArgs = if ($rest.Count -gt 1) { $rest[1..($rest.Count - 1)] } else { @() }
            fvm dart run build_runner watch --delete-conflicting-outputs @watchArgs
        } else {
            fvm dart run build_runner build --delete-conflicting-outputs @rest
        }
    }
    default {
        Write-Host 'Usage: .\dev.ps1 <setup|prod|profile|gen> [args]'
        Write-Host '  setup    fvm install + pub get + build_runner (seeds .env.* from .env.example)'
        Write-Host '  prod     run with --dart-define=ENV=prod'
        Write-Host '  profile  run with --profile --dart-define=ENV=prod'
        Write-Host '  gen      build_runner build (gen --watch to watch)'
        if ($cmd) { exit 1 }
    }
}
