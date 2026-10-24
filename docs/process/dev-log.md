# FocusFlow — Development Log

**Project:** COMP826 Mobile Systems Development — Milestone 2  
**Application:** FocusFlow  
**Development role:** Developer  
**Technology stack:** Flutter, Dart, SQLite  
**Architecture:** Model–View–Presenter (MVP)  
**Development methodology:** Scrumban

---

## 24 October 2026 — Environment and Project Initialisation

### Development Environment

| Component | Configuration |
|---|---|
| Operating system | Windows 11 |
| IDE | Visual Studio Code |
| Flutter SDK | 3.47.7 |
| Dart SDK | 3.13.5 |
| Android emulator | API 37 |
| Version control | Git and GitHub |
| Repository | SKGI00/FocusFlow |

### Completed Activities

- Initialised the Flutter application project and configured the Android development environment.
- Successfully built and executed the default Flutter application on an Android emulator.
- Established the Git repository, created the initial commit and pushed the project to the remote `main` branch.
- Configured the GitHub Projects Scrumban board with Backlog, Ready, In Progress, In Review and Done workflow stages.
- Established a work-in-progress limit of two concurrent development tasks.
- Created development issues covering session management, architectural refinement, SQLite persistence and distraction logging.
- Established the MVP directory structure and project documentation folders.

### Architectural Decisions

- Retained the MVP architectural pattern selected in Milestone 1.
- Selected SQLite for local, offline-first data persistence.
- Adopted automated testing and continuous integration as development quality practices.

### Identified Design Issue

Milestone 1 contained an architectural inconsistency between the MVP class diagram and the MVVM terminology used in its runtime sequence diagram. Architectural refinement was recorded as a separate development task.

---

## 24 October 2026 — SQLite Data Layer Implementation

### Implementation

- Defined data models for focus sessions, distraction events and post-session reflections.
- Implemented a local SQLite database helper and initial database schema.
- Established relational constraints for session-linked distractions and reflections.
- Implemented repository operations for creating, retrieving, updating and deleting session records.
- Added repository operations for distraction logging, distraction counts and reflection retrieval.
- Added database constraints for invalid session durations and duplicate reflections.

### Automated Verification

| Test ID | Verification objective | Result |
|---|---|---|
| D1 | Session insertion and retrieval | PASS |
| D2 | Distraction records linked to a session | PASS |
| D3 | Cascading deletion of associated distractions | PASS |
| D4 | One-reflection-per-session constraint | PASS |
| D5 | Rejection of invalid session duration | PASS |

**Test execution:** `flutter test test/database_test.dart`  
**Outcome:** 5/5 tests passed.

**Static analysis:** `flutter analyze`  
**Outcome:** No issues found.

### Code Quality

- Applied standard Dart code formatting.
- Removed a redundant package import identified by the Dart analyzer.
- Separated data models, database connection management and repository operations to support maintainability and testability.

### Current Limitations

- Automated database verification was performed using SQLite FFI on Windows.
- End-to-end database persistence on an Android device remains unverified.
- Focus-session timer and user interface integration remain outstanding.
- GitHub Actions continuous integration remains to be configured.

### Next Development Activities

- Commit and push the verified SQLite implementation.
- Configure GitHub Actions for automated analysis and testing.
- Implement the focus-session Presenter and Flutter timer interface.
- Integrate the timer with local session persistence.
- Extend automated testing to presenter logic and user interactions.

## 24 October 2026 — Focus Timer and Interface Development

### Implementation
- Implemented the SessionPresenter with custom durations, start, pause, resume, completion and reset controls.
- Developed the Flutter timer screen and reusable visual theme.
- Added session progress indication and non-judgmental feedback for sessions ended early.
- Replaced the original Flutter starter interface and widget test.

### Verification
- SessionPresenter unit tests: 8/8 passed.
- SQLite database tests: 5/5 passed.
- Flutter widget test: 1/1 passed.
- Full Flutter test suite: 14/14 passed.
- Flutter static analysis: No issues found.
- Android emulator: Timer interface and early-ending feedback verified.

### Outstanding
- SQLite integration with the timer.
- Distraction logging, reflection, history and other planned screens.
- Updated UML diagrams and further usability evaluation.


---

## 25 October 2026 — Integration, Android verification and final design documentation

**Iteration 2 checkpoint (developer record).** This entry updates—not retrospectively rewrites—the earlier 24 October development stages and provisional outstanding-item lists.

### Implemented and demonstrated

- Completed the Home → session → distraction → optional reflection → History journey in the Android emulator. Study tips, weekly insights and gentle streaks are implemented.
- Enabled and verified local, optional Android scheduled reminders, including a notification arriving at the configured 06:04 NZDT time. Settings and preferred duration persist.
- Verified offline operation in airplane mode, session completion, saving a reflection, and retrieving saved History after reopening.
- Found two real enlarged-font overflows in Reflection and Insights; corrected both and visually retested the layouts.
- Ran `flutter analyze` (no issues) and **58 local automated tests (all passing)**. GitHub Actions **CI #6** was reported green for the accessibility-fix commit `8eab48b`. Later README/UML documentation was pushed; capture a CI check for that newer commit before calling it the final tested revision.
- Completed an additional developer-performed **15-minute timed Android session**, checking its duration against a phone timer. Also checked distraction logging, pause/resume, background behaviour, reflection prompt and saved results, and persistence of default duration. All tested interactions were reported working. **Exact timing deviations, task completion seconds and tap counts were not recorded and must not be invented.**
- Replaced the default starter README and updated the UML diagrams based on the implemented MVP structure. The user confirmed the documentation commit/push and moved UML issue #2 to Done.

### Scope and design decisions

- Milestone 1 specified the MVP (Model–View–Presenter) architecture. Milestone 2 retained it, but consolidated one-tap distraction handling into `SessionPresenter` rather than implementing a separate `DistractionPresenter`; the implemented Home navigation is widget-based. Record these as design refinements and compare the diagrams explicitly.
- Focus Sounds is a **preview/concept only**, not an implemented audio playback feature. Further audio plugin work was declined to preserve required core functionality and regression-testing time.
- For in-progress sessions left by exiting through Back or closing the app, no crash or database-loss event was established. Minimising the app did not reproduce an issue. Session recovery after deliberate exit is a limitation/design choice rather than an established unexpected-crash defect.
- Only Android emulator behaviour was verified; iOS and physical lower-end device performance remain untested.

### Scrumban retrospective

**Iteration 1 (24 October):** Establish working toolchain, version control, CI, SQLite and MVP timer core. **Iteration 2 (25 October):** Complete the user journey, reminders, accessibility fixes, integration checks and current architecture documentation. WIP limit: two active tasks. Development was compressed relative to the original proposed schedule, leaving less time for independent usability participants, systematic performance profiling and physical-device validation. Automated tests and small increments reduced regression risks while scope was constrained.

### Remaining before submission

- Final evaluation analysis using **ISO/IEC 25010** and **PACMAD**, with clear distinction between functional passes and absent quantitative usability data.
- Final accessible, evidence-linked report (up to 4,000 words including references), updated Scrumban screenshot and repository checks, and final source ZIP submission.

**Evidence integrity:** Dates and evidence above reflect user-provided screen verification and checkpoints. Do not treat this addendum as independent testing by an external participant.
