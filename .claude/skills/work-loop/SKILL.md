---
name: work-loop
description: Iterative implement → verify → commit cycle on the current branch until the stated goal is done. No branch creation, no PR. Use when the user says "작업 루프", "work loop", or wants heads-down implementation of a defined task list.
---

# work-loop

Stay on the current branch and grind through a goal in small verified commits.

## Setup

1. Confirm you are on a work branch (`{type}/{N}-{slug}`), **not** `develop` or `main`. If on a base branch, stop and run `start-work` first.
2. Break the goal into a concrete task list (TaskCreate) — each task should be one committable unit (one widget, one bloc, one refactor).

## The loop

For each task, repeat until the list is empty:

1. **Implement** the task following the architecture in CLAUDE.md:
   - pages → `lib/feature/{domain}/presentation/pages/`, widgets → `lib/feature/{domain}/presentation/widgets/`, bloc triple → `lib/feature/{domain}/presentation/bloc/`, API → `lib/feature/{domain}/data/`
   - reuse `core/` tokens (AppSize, AppSpacing, AppRadius, theme colors/text styles) — no hardcoded magic numbers/colors
   - layout padding comes from `BaseScaffold`, not per-page
2. **Verify** with the `verify-loop` skill (analyze must pass; codegen/test as applicable). For publishing/UI tasks this includes the Appium `ui-test` stage — add/extend the page's spec in `appium/test/specs/` as part of the task.
3. **Commit** that unit alone: `{emoji} :: {한국어 요약}` (✨/♻️/💄/🎨/🐛/🔧).
4. Mark the task completed and move to the next.

## Exit

- Done when all tasks are completed and the last verify pass is green. Report what was committed (list of commit subjects) and suggest `ship` if the issue scope is complete.
- Blocked? Stop after 2 failed re-diagnoses of the same error and report findings instead of looping forever.
