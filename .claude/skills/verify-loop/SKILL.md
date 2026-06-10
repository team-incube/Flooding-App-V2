---
name: verify-loop
description: Run the CI-equivalent verification chain (build_runner codegen → flutter analyze → flutter test) and keep fixing + re-running until everything passes. Use before committing, before PRs, or when the user says "검증", "verify", "CI 통과 확인".
---

# verify-loop

Mirror `.github/workflows/flutter-ci.yaml` locally and iterate until green.

## Preconditions

- `.env.dev` / `.env.prod` must exist (gitignored). If missing, copy `.env.example` to both names — otherwise analyze fails with `asset_does_not_exist`.
- Run `flutter pub get` if dependencies changed.

## The loop

Repeat until all steps pass (max 5 iterations, then stop and report what's still failing):

1. **Codegen** (only if generated files are involved — retrofit/freezed/json_serializable changes):
   ```
   dart run build_runner build --delete-conflicting-outputs
   ```
2. **Analyze** (CI gate — infos allowed, warnings/errors are not):
   ```
   flutter analyze --no-fatal-infos
   ```
3. **Test** (only if `test/` contains `*_test.dart` files):
   ```
   flutter test
   ```
4. If any step fails: read the error, fix the **root cause** in source (never silence lints with `// ignore` or delete tests to pass), then re-run from the failed step.

## Rules

- Fix code, not the checks. Loosening `analysis_options.yaml` or skipping tests requires explicit user approval.
- If the same error survives 2 fix attempts, step back and re-diagnose instead of retrying variations.
- Finish with a one-line verdict per step (pass/fail/skipped and why).
