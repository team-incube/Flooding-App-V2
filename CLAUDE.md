# CLAUDE.md

Flutter app (package `flooding_v2`) for GSM dormitory life — study requests, massage chair requests, wake-up music, AI chatbot. Repo: `team-incube/Flooding-App-V2`. Default/base branch for PRs: `develop`.

## Setup & Commands

The Flutter SDK is pinned via FVM (`.fvmrc` → 3.44.0). Prefix Flutter/Dart commands with `fvm` so everyone uses the pinned SDK:

```bash
fvm install                          # after clone: download the pinned SDK (reads .fvmrc)
fvm flutter pub get
fvm dart run build_runner build      # generates *.g.dart / *.freezed.dart (not committed)
fvm flutter analyze --no-fatal-infos # CI gate
fvm flutter test                     # CI runs only if test/ contains *_test.dart
fvm flutter run --flavor dev         # build flavor selects env; pass --flavor prod for prod
```

Dev task runner at the repo root: `dev.ps1` (Windows) / `dev.sh` (macOS/Linux). Call by path with a subcommand — `.\dev.ps1 prod` or `./dev.sh prod` (PowerShell needs the `.\` prefix):

| Subcommand | Does |
|---|---|
| `setup` | `fvm install` + `pub get` + `build_runner build`; seeds missing `.env.dev`/`.env.prod` from `.env.example` |
| `dev` | `fvm flutter run --flavor dev` |
| `prod` | `fvm flutter run --flavor prod` |
| `profile` | `fvm flutter run --profile --flavor prod` |
| `gen` | `fvm dart run build_runner build` (`gen --watch` to watch) |

Extra flags pass through, e.g. `.\dev.ps1 prod -d emulator-5554`. Both scripts bail early if `fvm` isn't installed.

Optional `flooding` shortcut (per-machine, not committed) — drop a shell function in your profile so you can run `flooding prod` from any directory instead of `.\dev.ps1 prod`. It walks up from the cwd to find `dev.ps1`/`dev.sh`, falling back to a hardcoded repo path.

```powershell
# PowerShell: add to $PROFILE
function flooding {
    $fallback = 'C:\path\to\Flooding-App-V2'   # your repo path
    $dir = (Get-Location).Path; $script = $null
    while ($dir) {
        $c = Join-Path $dir 'dev.ps1'
        if (Test-Path $c) { $script = $c; break }
        $p = Split-Path $dir -Parent; if ($p -eq $dir) { break }; $dir = $p
    }
    if (-not $script) { $script = Join-Path $fallback 'dev.ps1' }
    & $script @args
}
```

```sh
# zsh/bash: add to ~/.zshrc (or ~/.bashrc)
flooding() {
    local fallback="$HOME/path/to/Flooding-App-V2"   # your repo path
    local dir="$PWD" script=""
    while [ -n "$dir" ]; do
        if [ -f "$dir/dev.sh" ]; then script="$dir/dev.sh"; break; fi
        [ "$dir" = "/" ] && break; dir="$(dirname "$dir")"
    done
    [ -z "$script" ] && script="$fallback/dev.sh"
    "$script" "$@"
}
```

- Env is selected by the **build flavor** (`--flavor {dev|prod}`). `lib/core/config/env.dart` reads the active flavor via `appFlavor` (defaults to `dev` when none, e.g. `flutter test`) and loads `.env.{flavor}`. Android `productFlavors` live in `android/app/build.gradle.kts`; `dev` gets `applicationIdSuffix .dev` so dev/prod install side by side. Because flavors are defined, **every `flutter build`/`run` needs `--flavor`** (CI and the appium build pass it). `--profile` is a Flutter build mode (perf), orthogonal to flavor. (iOS flavor schemes are not yet configured — needs Xcode/macOS; tracked separately.)
- `.env.dev` and `.env.prod` are gitignored but declared as pubspec assets. After clone (or if analyze fails with `asset_does_not_exist`), copy `.env.example` to both names.
- CI reads the pinned version from `.fvmrc` (`flutter-ci.yaml`, `appium-ui.yml`).

### Appium UI tests (required for publishing/UI work)

```bash
cd appium
npm install && npm run driver:install   # one-time
npm run build:app                       # APK with auth-bypass entrypoint (integration_test/appium_test.dart)
npm test                                # wdio + appium-flutter-integration-driver, default udid emulator-5554
```

Specs: `appium/test/specs/{feature}.e2e.ts` (WebdriverIO TS, `flutterByText$`/`flutterByValueKey$` locators). Android SDK lives at `%LOCALAPPDATA%\Android\Sdk` (not on PATH); AVDs: `flooding`, `goms`. See the `ui-test` skill and `appium/README.md`. CI runs the same suite on an emulator (`.github/workflows/appium-ui.yml`) for PRs touching `lib/`, `integration_test/`, `appium/`, or `pubspec.yaml`.

## Architecture

- `lib/core/` — shared infrastructure: `config`, `constants` (AppSize, AppSpacing, AppRadius...), `enum`, `network` (dio + retrofit), `route` (go_router, ShellRoute in `route.dart`, paths in `route_path.dart`), `theme` (color/text_style/icon tokens, SUIT font), `utils`, `widgets` (BaseScaffold, drawer, floating button, sheets).
- `lib/feature/{domain}/` — feature modules (`ai`, `auth`, `dormitory`, `home`, `member`, `profile`, `study`):
  - `presentation/pages/` — route-level pages (`*_page.dart`)
  - `presentation/widgets/` — feature widgets; large page bodies are split into `*_view.dart`
  - `presentation/bloc/` — flutter_bloc (`*_bloc.dart`, `*_event.dart`, `*_state.dart`)
  - `presentation/models/` — presentation models / view models
  - `data/datasources/`, `data/models/` — API layer (retrofit datasources, freezed/json_serializable models)
- State management: `flutter_bloc`. Navigation: `go_router`. HTTP: `dio` + `retrofit`. Codegen: `freezed`, `json_serializable`, `retrofit_generator` via `build_runner`.
- Shared layout (padding, app bar, drawer) lives in `BaseScaffold` (`lib/core/widgets/scaffold/base_scaffold.dart`) — don't re-add per-page horizontal padding.

## Language Policy

- Code identifiers, file names, and this documentation: **English**.
- Commit messages, PR titles/bodies, issue titles/bodies, review replies: **Korean**.

## Git Conventions

### Branches

`{type}/{issue-number}-{kebab-case-slug}` off `develop`. Types:

| Type | Use | Usual commit emoji |
|---|---|---|
| `feature` | new pages, publishing (`🐋 Type: Publish`), new functionality | ✨ |
| `refactor` | restructuring existing code without behavior change | ♻️ |
| `chore` | tooling, CI, config, docs — anything outside product code | 🔧 |

Example: `feature/23-publish-ai-chat-page`, `chore/25-setup-claude-harness`.

### Commits

`{emoji} :: {Korean summary}` — one logical change per commit. Emoji map (observed in history):

| Emoji | Use |
|---|---|
| ✨ | new feature / page |
| ♻️ | refactor / review feedback (`♻️ :: 코드 리뷰 반영 — ...`) |
| 💄 | UI/style tweak |
| 🎨 | formatting only |
| 🐛 | bug fix |
| 🔧 | config / CI / tooling |

Adding `[CI]` to a push commit message triggers Flutter CI on push (PRs always run CI).

### Pull Requests

- Title **must** match CI regex `^[^ ] :: \(#[0-9]+\) - .+`:
  `🔀 :: (#{issue-number}) - {Korean title}` (e.g. `🔀 :: (#42) - 로그인 기능 추가`).
- Body follows `.github/PULL_REQUEST_TEMPLATE.md` (개요 / 관련 이슈 `Closes #N` / 작업내용 / 테스트 방법 / 스크린샷 / 질문사항 / 체크리스트), written in Korean.
- Base branch: `develop`.

### Issues

- Titles: plain Korean, no emoji prefix (e.g. `AI 챗봇 대화 페이지 퍼블리싱`).
- Use `.github/ISSUE_TEMPLATE/` (TODO/Bug: `## Describe` + `## Additional`).
- Labels: `🐋 Type: Publish`, `📩 Type: Feature/Function`, `🐞 Type: Bug/Function`, `🪳 Type: Bug/UI`, `📜 Type: Feature/Document`, plus `⚠️ Priority: *` and `🌟 Status: *`.

## Workflow Skills

Project skills in `.claude/skills/`:

- `/start-work [issue#]` — pick/confirm an issue, create the convention branch off fresh `develop`.
- `/verify-loop` — codegen → analyze → test (+ Appium `ui-test` for publishing/UI changes); fix and repeat until green.
- `/ui-test` — run the Appium UI suite on the emulator; mandatory for `🐋 Type: Publish` / UI changes.
- `/ship` — commit remaining work, push, open a PR that passes the title check.
- `/work-loop` — implement → verify → commit cycle on the current branch.
- `/full-loop` — full cycle for one issue: start-work → work-loop → ship.
