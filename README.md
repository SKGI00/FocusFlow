# FocusFlow

FocusFlow is an offline-first Flutter prototype for gentle study-focus support. It was developed for the COMP826 Mobile Systems Development assessment at Auckland University of Technology, following the Developer role defined in Milestone 1.

**Repository:** https://github.com/SKGI00/FocusFlow

## Features

- Flexible focus timer with start, pause, resume and end actions
- One-tap tagged distraction logging during sessions
- Optional post-session reflection with supportive, non-judgemental wording
- Local session history, weekly insights and gentle consistency/streak feedback
- Offline study and digital-wellbeing tips
- Settings for focus duration and optional scheduled local study reminders
- Local SQLite persistence; no account or cloud synchronisation required for core use

## Technology

- Flutter and Dart; developed with Flutter **3.47.7** and Dart **3.13.5**
- `sqflite` and `path` for local records
- `shared_preferences` for user settings
- `fl_chart` for visual insights
- `flutter_local_notifications`, `flutter_timezone` and `timezone` for Android reminders
- Model–View–Presenter (MVP) separation, with presenters and repositories for application and persistence logic
- GitHub Actions for automated analysis and tests

## Running the project (Windows)

### Prerequisites

Install Flutter 3.47.7 (or a compatible version supporting Dart 3.13.5), Android Studio with an Android SDK and emulator, and Git. Ensure Flutter and Android tooling are configured:

```powershell
flutter doctor -v
flutter devices
```

### Install, run and test

From a Windows PowerShell terminal:

```powershell
git clone https://github.com/SKGI00/FocusFlow.git
cd FocusFlow
flutter pub get
flutter run
```

Select a running Android emulator/device if Flutter asks for one. To run automated checks:

```powershell
flutter analyze
flutter test
```

For release-build verification when Android tooling is configured:

```powershell
flutter build apk --release
```

## Main project folders

| Path | Purpose |
| --- | --- |
| `lib/view/` | Screens for home, sessions, reflection, history, insights, tips and settings |
| `lib/presenter/` | Session and reflection presentation logic |
| `lib/model/` | Local data models |
| `lib/data/` | SQLite database helper and repositories |
| `lib/analytics/` | Weekly insights and consistency logic |
| `lib/settings/` | Persisted preferences |
| `lib/notifications/` | Local reminder scheduling |
| `test/` | Dart/Flutter unit and widget tests |
| `.github/workflows/ci.yml` | Continuous integration checks |
| `docs/process/` | Development logs, planning and assessment evidence |

## Verification and supported platforms

The prototype was developed and manually tested on an **Android emulator**. Development verification recorded **58 passing automated tests** and a green GitHub Actions CI run for commit `8eab48b` (25 October 2026 NZDT). Manual Android checks covered a full 15-minute session, pause/resume, backgrounding, distractions, session completion/reflection, preferences persistence, local notification scheduling, offline use and history persistence. These are developer-performed checks rather than an independent user study. The recorded timer check was compared with a phone stopwatch; the exact deviation was not logged.

Flutter includes other platform directories, but **iOS and physical-device compatibility have not been validated**. Do not infer performance or battery characteristics that have not been measured.

## Known limitations / scope

- Leaving an active session using Back or terminating the application without ending the session can retain an unfinished session record. Minimising/backgrounding was verified in the developer test. Explicit interruption recovery is a potential future improvement.
- Local SQLite records are application-local but **are not claimed to be encrypted**.
- This is an academic prototype, not a clinically validated intervention or a production release.
- Cloud accounts, data synchronisation, AI coaching and automatic distraction/app blocking are intentionally out of scope.
- The application does not claim validated iOS operation or measured low battery/CPU consumption.

## Licence

Academic coursework project. No open-source licence has been declared; do not assume permission to reuse beyond applicable law.
