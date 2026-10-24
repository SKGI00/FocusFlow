# FocusFlow — Submission and evidence map (25 Oct 2026)

## ONE canonical project

The **only working app** is the Flutter folder opened in VS Code, e.g. `C:\Users\G_Shr\Projects\focusflow`.
Previous `FocusFlow_*.zip` downloads were **patch packages**, not separate apps or submission files. Extract each patch into the canonical folder *once* and verify. Do **not** submit these patch ZIPs separately.

## Structure to aim for

```text
focusflow/
  .github/workflows/ci.yml
  android/  ios/  (Flutter platform projects)
  lib/ (Flutter source; model/, presenter/, view/, data/, analytics/, theme/)
  test/ (unit/widget tests)
  docs/
    uml/                <- corrected class/sequence/component/deployment diagrams
    process/
      dev-log.md        <- real iteration log
      planned_vs_actual.md
      assessment_handoff.md
      evidence/           <- labelled screenshots
  evaluation/
    protocol.md          <- actual test procedure and acceptance criteria
    results.md           <- real counts, measurements and analysis
  README.md              <- setup, source layout, features, limitations
  pubspec.yaml, pubspec.lock
```

## Milestone 2 final items (check against current Canvas instruction)

1. **Final written report** (up to **4,000 words, including references**, 11/12-pt body, final word count), including original project scope, tested features/screenshots, changes since M1, corrected UML, Scrumban and planned-v-actual Gantt, ISO/IEC 25010 + PACMAD results, limitations, recommendations, GitHub URL and tested commit. Submit in the document format required by Canvas (typically DOCX/PDF; check the live submission page).
2. **One ZIP of the final `main` branch**, made **only after** all changes are committed and pushed. Do not ZIP Downloads or package `build/`, `.dart_tool/`, `.git/`, or separate patch ZIPs. The repo includes a clear README and source/testing/documentation files.
3. **GitHub main branch** that matches the ZIP and CI-green commit; no need to submit each historical update ZIP.
4. **Any separate video/demo or other artefact only if the actual Canvas brief asks for it.** Do not assume one is required.

## Last verified baseline, not the final state

- Commit `a764919`: green GitHub CI #3 for Home/Reflection/History/Tips at that point.
- Local developer verified those screens and persistence on Android 25 Oct.
- New 15/30/60/Custom timer, sound concept, warm visuals, analytics and this revised reflection were introduced afterwards. **They need a fresh `flutter analyze`, `flutter test`, Android run and CI push before being claimed as final.**
- **Audio is NOT a completed feature:** optional expanded UI preview only, no `audioplayers` dependency or sound playback. Document explicitly in limitations/future work.
- **Cross-platform:** Flutter code targets multiple platforms; iOS has not been independently tested. Do not claim iOS verified.

## Scrumban update on GitHub Projects

- Inspect existing issues **#1 timer, #2 UML correction, #3 SQLite foundation, #4 distraction logging**. Move only if the actual acceptance criteria on each issue are verified. Keep WIP max 2.
- Add remaining cards as appropriate: "Finish Settings and local reminders", "Verify insights and streaks", "Correct UML diagrams", "Run ISO/PACMAD evaluation", "Final report/README/submission".
- Preserve realistic statuses: an implementation is not **Done** solely because a UI button exists.
- Save one board screenshot **now**, then another after final verification to demonstrate process changes.

## Final archiving

Use `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\create_submission_archive.ps1` from the project root **after** tests pass, all files are committed, CI green, and main pushed. The script creates a clean ZIP from your actual commit, not from the earlier patch packages.
