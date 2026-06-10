---
name: full-loop
description: Full autonomous cycle for one issue - start-work (issue → branch) → work-loop (implement/verify/commit) → ship (push → PR). Use when the user says "전체 루프", "full loop", "이슈 끝까지", or hands over an issue to complete end-to-end.
---

# full-loop

One issue, end to end: branch → implementation → verified commits → PR.

## Pipeline

1. **start-work** — resolve the issue (given number, or ask), create `{type}/{N}-{slug}` off fresh `develop`, label the issue in progress.
2. **Plan** — read the issue body and any linked designs; map the work onto the feature structure (`lib/feature/{domain}/...`); create the task list. If the issue is ambiguous on scope or design, ask **before** implementing, not after.
3. **work-loop** — implement → verify-loop → commit per unit, until the task list is empty.
4. **ship** — final verify, push, open the PR (`🔀 :: (#{N}) - 제목`, Korean template body, base `develop`), set the issue to Reviewing.
5. **Report** — PR URL, commit list, verification verdicts, and anything intentionally left out of scope.

## Guardrails

- One issue per cycle. If new scope is discovered mid-loop, file a new issue (Korean title, TODO template) instead of widening the branch.
- Human gates: merging the PR and responding to review are out of scope — stop after the PR is open.
- Review feedback round-trips use commits prefixed `♻️ :: 코드 리뷰 반영 — ...` on the same branch (only when the user asks to address review comments).
- If verification cannot be made green within the work-loop's retry budget, open no PR; report the blocker instead.
