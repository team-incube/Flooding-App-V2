---
name: ui-test
description: Run Appium UI tests (appium-flutter-integration-driver + WebdriverIO) on an Android emulator. Required verification for publishing/UI work. Use when the user says "UI 테스트", "appium", or after implementing/changing any page or widget.
---

# ui-test

Run the Appium UI suite in `appium/` against an Android emulator.

## Preconditions (check in order, fix what's missing)

1. **Emulator running:** `& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" devices` shows a `device` entry. If not, cold-boot one:
   `& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd flooding -no-snapshot-load` (background), then wait until `adb shell getprop sys.boot_completed` returns `1`. (A snapshot-restored boot can leave networking in a bad state — see the `emulator-internet-false-alarm` memory.)
2. **npm deps:** `appium/node_modules` exists, else `npm install` in `appium/`. `postinstall` runs `patch-package`, which reapplies `patches/wdio-flutter-by-service+1.3.0.patch` (Windows ESM `pathToFileURL` fix — without it `flutterBy*$` throws `ERR_UNSUPPORTED_ESM_URL_SCHEME`).
3. **Driver installed:** `npm run driver:list` shows `flutter-integration`, else `npm run driver:install` (needs Appium server v3). `driver:install` is idempotent — if already installed it falls back to `appium driver update`, so it never fails with "already installed".
4. **Test APK up to date:** if any `lib/` or `integration_test/` file is newer than `build/app/outputs/flutter-apk/app-debug.apk`, rebuild:
   `npm run build:app` (= `flutter build apk --debug --target integration_test/appium_test.dart`). First build is slow (~10 min, compiles the integration_test + appium_flutter_server deps).

## Run

```
cd appium
npm test            # starts/stops the Appium server itself (wdio appium service)
```

Different device: set `ANDROID_UDID` env var (default `emulator-5554`).

## Writing/extending tests

- One spec per page/feature: `appium/test/specs/{feature}.e2e.ts`.
- Locators: `browser.flutterByText$('...')` / `flutterByValueKey$` / `flutterBySemanticsLabel$`. Prefer `ValueKey`s on interactive widgets when adding new UI — add keys in the widget code rather than matching on translatable text.
- The test APK bypasses OAuth (fake token storage in `integration_test/appium_test.dart`) and boots straight to home. Navigate to the target page via the drawer/routes inside the test.
- For a new publishing page, minimum coverage: page opens via navigation + key elements visible + primary interaction (tap/input) does not crash.

## On failure

- Read the wdio/appium log output; distinguish app bugs (fix in `lib/`) from test/locator issues (fix the spec).
- Same rules as verify-loop: fix root causes, max 5 iterations, report failures honestly.
