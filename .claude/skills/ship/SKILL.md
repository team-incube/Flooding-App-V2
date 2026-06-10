---
name: ship
description: Finish the current branch — verify, commit remaining work with the emoji-:: convention, push, and open a PR to develop that passes the PR title check CI. Use when the user says "PR 올려", "출고", "ship", "머지 준비".
---

# ship

Take the current branch from "code done" to "PR open" following repo conventions.

## Steps

1. **Identify the issue number** from the branch name (`{type}/{N}-{slug}`). If it doesn't contain one, ask the user — the PR title check CI requires `(#N)`.
2. **Verify first:** run the `verify-loop` skill. Do not push failing code.
3. **Commit** any remaining changes in Korean, one logical change per commit:
   ```
   {emoji} :: {한국어 요약}
   ```
   Emoji: ✨ feature · ♻️ refactor · 💄 UI/style · 🎨 format · 🐛 bugfix · 🔧 config/CI. Never commit `.env.dev`/`.env.prod` or generated `*.g.dart`/`*.freezed.dart` files.
4. **Push:** `git push -u origin {branch}`.
5. **Open the PR** against `develop`:
   - Title (must match CI regex `^[^ ] :: \(#[0-9]+\) - .+`):
     `🔀 :: (#{N}) - {한국어 제목}`
   - Body: fill `.github/PULL_REQUEST_TEMPLATE.md` in Korean — 개요, `Closes #{N}`, 작업내용 (bulleted actual changes), 테스트 방법 (concrete steps), 스크린샷 (placeholder note if UI changed but no screenshot available), 질문사항, 체크리스트 (check only what was actually verified).
   - **Korean body encoding (Windows/PowerShell):** never pipe a here-string into `gh ... --body-file -` — PowerShell 5.1 encodes native-command stdin in the system codepage and mangles Hangul into `?`. Write the body to a UTF-8 file first, then pass its path:
     ```
     gh pr create --base develop --title "🔀 :: (#{N}) - {제목}" --body-file pr_body.md
     ```
     (Same for `gh pr edit --body-file` and `gh issue create/edit --body-file`.) Use the `Write` tool to create the file (it writes UTF-8), then delete it after. The PR **title** via `--title "..."` is fine inline.
6. **Update the issue label** to `🌟 Status: Reviewing`.
7. Report the PR URL and the verification results.

## Constraints

- Base branch is always `develop` (never `main`).
- Don't merge the PR or enable auto-merge — review is human-gated.
- If the branch is behind `develop`, merge `develop` in and re-verify before pushing.
