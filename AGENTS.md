# AGENTS.md — Klinik-Scan

Medical triage aid for rural Central Africa. Flutter + Firebase, offline-first.
Do **not** read this if you have loaded `CLAUDE.md` — this is a compact supplement.

## Règle absolue

**Ne jamais modifier aucun fichier de ce projet sans l'autorisation explicite du propriétaire (Ashad).**

## Before any task

1. Read `PROGRESS.md` — state of truth, last session details, next steps.
2. Load the matching skill from `klinik-skills/` for the domain you're working on.
3. Read `CLAUDE.md` for project rules (non-negotiables, architecture).

## Quick commands

```bash
flutter run -d emulator-5554     # Run on emulator (detaches without terminal)
adb shell am start -n com.klinik.klinik/.MainActivity  # Relaunch installed APK
flutter analyze                   # REQUIRED before any commit — 0 errors expected
flutter test                      # Current: 3 tests, all green
flutter test test/path/to/test    # Single test file
flutter build apk --release       # Release build
flutter clean && flutter pub get  # Full cache reset
```

## Riverpod — no codegen

All providers are **hand-written** (`final fooProvider = Provider<Foo>((ref) => ...)`).
No `*.g.dart` files exist. Do **not** use `@riverpod` annotations.
`build_runner` / `riverpod_generator` are in pubspec but unused.

## Build quirks (Windows machine)

- `kotlin.incremental=false` in `android/gradle.properties` (project on `E:\`, pub cache on `C:\`).
- compileSdk 36 overridden per subproject in `android/build.gradle.kts` via `afterEvaluate` with `state.executed` guard.
- Gradle 9.1 + AGP 9.0 — DSL is strict.
- Emulator: always reinstall APK after restart (quickboot rolls back to old APK).
- Emulator network freeze fix: launch with `-dns-server 8.8.8.8`.

## Architecture essentials

- Feature-first: `lib/features/{auth,onboarding,home,patient,scan,validation,settings}/`
- Couches: `data/` (repositories), `application/` (providers), `presentation/` (screens/widgets)
- No cross-feature imports — use `core/` or `shared/` only
- All Firestore paths: `/entities/{entityId}/...` — never cross entity boundaries
- Session via `SessionStore` (Flutter Secure Storage), **not** Firebase custom claims (plan Spark, Option B)
- Anonymous auth used for join flow (`linkWithCredential` at activation)
- Repositories receive dependencies via constructor (`const Repo(this._db)`), never `BuildContext`

## Style constraints

| What | Rule |
|---|---|
| Colors | Only `KlinikColors.*` — no hex in widgets |
| Typography | Only 4 sizes from `KlinikTypography` |
| Spacing | 8pt grid (`KlinikSpacing.*`) |
| Icons | `lucide_icons_flutter` (fork) only — no Material Icons |
| Font | Inter via `google_fonts` only |
| Tap targets | min 48×48 dp (52 dp for scan buttons) |
| Network status | `NetworkStatusIndicator` on every AppBar screen |
| Offline writes | Never show error toasts — Firestore handles silently |
| Media uploads | Always via `SyncQueueService`, never direct |

## Firebase

- Project: `klinik-95a79`
- Rules: Option B (no custom claims). Deployed via `firebase deploy --only firestore:rules`
- **Do not** enable Blaze / Cloud Functions / FCM / Storage without founder announcement
- Auth: Email/Password + Anonymous (for join flow)
- `flutterfire configure` already ran — `lib/firebase_options.dart` is live

## Existing routes

| Path | Screen |
|---|---|
| `/` | SplashScreen |
| `/onboarding` | OnboardingScreen (4 slides) |
| `/auth` | AuthChoiceScreen |
| `/auth/login` | LoginScreen |
| `/auth/create` | CreateEntityScreen (2-step) |
| `/auth/join` | JoinEntityScreen |
| `/auth/activate` | ActivateAccountScreen |
| `/home` | HomeScreen (role-based) |
| `/home/requests` | PendingRequestsScreen (admin) |
| `/home/patients`, `/home/patients/new`, `/home/scan`, `/home/validation`, `/home/settings` | Placeholder routes |

## Skills (load before domain work)

| Domain | Skill path |
|---|---|
| Firestore rules / Auth / Storage | `klinik-skills/klinik-firebase-rules/SKILL.md` |
| Camera / Face analysis / Vision | `klinik-skills/klinik-vision-module/SKILL.md` |
| Offline / Sync / Hive | `klinik-skills/klinik-offline-sync/SKILL.md` |
| Widgets / Colors / Typography | `klinik-skills/klinik-design-system/SKILL.md` |

Design tokens priority: `_project/DESIGN.md` > `klinik-design-system/SKILL.md`.

## Topics deferred to V1.1 (do not implement)

- Vision module (MediaPipe, face analysis)
- PDF generation (`dart:pdf` + `printing` — commented out in pubspec)
- Google Mobile Ads (commented out)
- Windows Desktop dashboard
- iOS (V1.2)
- Firebase Storage (requires Blaze plan)
