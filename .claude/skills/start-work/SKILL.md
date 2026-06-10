---
name: start-work
description: Start work on a GitHub issue — pick or create the issue, then create the convention branch ({type}/{issue}-{slug}) off fresh develop. Use when the user says "이슈 시작", "작업 시작", "start issue", or names an issue number to work on.
---

# start-work

Turn a GitHub issue into a ready-to-work branch following repo conventions.

## Steps

1. **Resolve the issue.**
   - If an issue number was given: `gh issue view {N}` to confirm title/labels.
   - If not: `gh issue list --state open` and ask the user which one (or, if they described new work, create an issue first: Korean plain title, body using the TODO template sections `## Describe` / `## Additional`, appropriate `Type:` label).
2. **Pick the branch type** from the issue's nature:
   - `feature/` — new pages, publishing (`🐋 Type: Publish`), new functionality
   - `refactor/` — restructuring existing code
   - `chore/` — tooling, CI, docs, config
3. **Create the branch off fresh develop:**
   ```
   git checkout develop
   git pull origin develop
   git checkout -b {type}/{N}-{kebab-slug}
   ```
   Slug: short English kebab-case from the issue title (e.g. issue #23 "AI 챗봇 대화 페이지 퍼블리싱" → `feature/23-publish-ai-chat-page`). Match existing patterns: publishing issues use `publish-{page}`.
4. **Mark the issue in progress:** add label `🌟 Status: in Progress` (remove `🌟 Status: To Do` if present):
   ```
   gh issue edit {N} --add-label "🌟 Status: in Progress"
   ```
5. Report the issue number, branch name, and that the working tree is ready.

## Constraints

- Never branch off anything but up-to-date `develop` unless the user explicitly says otherwise.
- If the working tree is dirty, stop and ask before switching branches.
