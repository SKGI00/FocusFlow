# FocusFlow — Planned versus actual (M1 to M2)

**Updated:** 25 October 2026 (NZDT)  
**Basis:** Milestone 1 submitted Gantt, 24–25 October source/CI history, developer-performed Android verification.

## Discrepancy disclosed

The submitted Milestone 1 Figure 5 labels its planned schedule **August–October 2026**, as verified directly from page 10 of the submitted report. The actual recorded implementation was concentrated on **24–25 October 2026**, after the originally planned timeframe. The chart uses blue for planned phases, teal for documented work, and amber hatching for evaluation/report work still in progress at the 25 October checkpoint. The panels use **separate horizontal time scales within the same year** so both the multi-week plan and two-day actual activity are legible. Approximate phase boundaries are transcribed from the Milestone 1 graphic and are not exact task timestamps.

| Milestone 1 planned phase | Observed Milestone 2 work | 25 October checkpoint |
|---|---|---|
| Setup and planning | Flutter/Android emulator, VS Code, GitHub repo, WIP-2 Scrumban and CI configured on 24 Oct | Completed |
| Core features | Session timer and local SQLite on 24 Oct; distraction/reflection/History integrated and verified by 25 Oct | Completed in tested user journey |
| Advanced features | Weekly insights, streaks, Settings and scheduled local reminders by 25 Oct | Implemented; scheduled reminder independently seen |
| Testing and accessibility | Unit/widget regression suite, airplane-mode checks, 15-minute end-to-end run, enlarged-font fixes on 25 Oct | 58 tests passing, CI #6 green at code checkpoint |
| Evaluation and final report | Developer verification gathered; UML and README corrected on 25 Oct | ISO/PACMAD analysis and final report still to complete |

## Scrumban reflection

Development was organised into two short dated iterations rather than multi-week Scrum sprints. Iteration 1 on **24 October** focused on delivery foundations, timer and persistence. Iteration 2 on **25 October** focused on integration, UI, reminders, regression checks and architecture corrections. The board workflow is **Backlog → Ready → In Progress → In Review → Done**, with **WIP limit 2** in In Progress. The initial design over-specified separate Presenters; implementation consolidated distraction handling in SessionPresenter. Re-scoping audio to a preview prevented an unrelated dependency from jeopardising release checks. Late integration compressed time for non-developer testing and performance profiling—an explicit process limitation to discuss under evaluation and recommendations.

## Accuracy boundaries

- Local tests and CI results are from the user's reported screenshots/terminal runs; the graph does not imply external verification.
- The 15-minute duration was checked against a phone timer, but no exact deviation was recorded, so avoid "0-second error" or numerical accuracy claims.
- iOS and physical-device quality measures have not been tested.
- The final documentation commit may differ from the last fully tested code commit `8eab48b`; verify the final repository state at submission.
- No meetings, external testers, planned sprint reviews or earlier implementation dates were fabricated.

**Report figure:** `docs/process/evidence/16_Planned_vs_Actual_Gantt.png`  
**Suggested caption:** *Figure X. Milestone 1 proposed phase schedule and documented Milestone 2 implementation, displayed on separate time scales within 2026.*
