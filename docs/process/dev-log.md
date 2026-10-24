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
| T1 | Session insertion and retrieval | PASS |
| T2 | Distraction records linked to a session | PASS |
| T3 | Cascading deletion of associated distractions | PASS |
| T4 | One-reflection-per-session constraint | PASS |
| T5 | Rejection of invalid session duration | PASS |

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