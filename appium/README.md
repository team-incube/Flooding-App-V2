# Appium UI Tests

Appium + [appium-flutter-integration-driver](https://github.com/AppiumTestDistribution/appium-flutter-integration-driver) + WebdriverIO (TS) UI tests for publishing/UI verification.

## One-time setup

```bash
cd appium
npm install              # postinstall runs patch-package (Windows ESM fix for wdio-flutter-by-service)
npm run driver:install   # installs appium-flutter-integration-driver into ~/.appium (needs Appium v3)
```

> The `patches/` folder holds a one-line fix to `wdio-flutter-by-service` so `flutterBy*$` locators work on Windows (raw `C:\...` paths must be `file://` URLs for ESM `import()`). It is reapplied automatically on every `npm install`.

## Run

```bash
# 1. Start an Android emulator (e.g. AVD "flooding"), check udid with adb devices
# 2. Build the test APK (auth bypassed via integration_test/appium_test.dart):
npm run build:app

# 3. Run the suite (starts/stops the Appium server itself):
npm test

# Different device:
ANDROID_UDID=emulator-5556 npm test
```

## Writing tests

- Specs live in `test/specs/*.e2e.ts`.
- Find Flutter widgets with `browser.flutterByText$('...')`, `browser.flutterByValueKey$('...')`, `browser.flutterBySemanticsLabel$('...')`.
- The app boots straight to home (fake token storage in `integration_test/appium_test.dart`); screens that need real API data must mock or skip those parts.
- One spec file per page/feature, named after the feature (e.g. `ai-chat.e2e.ts`).
