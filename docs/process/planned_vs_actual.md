# FocusFlow — Planned versus actual development (M1 → M2)

**Status:** Working evidence document, dated 25 October 2026 NZDT. This is NOT a claim that all tasks are complete. Replace draft statuses with verified Git commits, tests, screenshots, and board records before submitting.

## Important date discrepancy in Milestone 1

The original M1 Gantt (Figure 5, section 2.3) shows an **August–October 2025** calendar. The verified development work described below occurred in **October 2026**. Keep the original M1 figure as proposed evidence; do **not** edit its dates to create a false plan. In the report, acknowledge this planning/date inconsistency and use the M1 **phase sequence** as the baseline for a clear planned-versus-actual discussion. If this was a drafting error in M1, state that honestly.

| M1 phase / planned sequence | Actual evidence in M2 | Status / variance |
|---|---|---|
| 1. Project setup and planning | Flutter/Android/VS Code/GitHub and Scrumban board established 24 Oct 2026 | Implemented later than dated M1 Gantt |
| 2. Core functionality: timer, SQLite, distractions, reflection | Timer and SQLite tested; Home/Reflection/History Android journey verified 25 Oct; CI #3 green on a764919 | Core screens working; interruption recovery needs checking |
| 3. Advanced: weekly insights, streaks, local notifications | Insights/streak source added 25 Oct; real-data chart needs a manual cross-check; local reminders/settings outstanding | Partial |
| 4. Quality assurance and testing | GitHub CI #3 green, 20 tests before later updates; later test counts require a fresh run; screen checks by developer | Partial: accessibility, offline and measured performance pending |
| 5. Final evaluation and reporting | Report draft and rubrics available; final as-built diagrams, quantitative ISO/IEC 25010 and PACMAD evaluation, results/conclusions needed | Not complete |

## Scrumban and retrospective — factual notes to develop

- Workflow: Backlog → Ready → In Progress (WIP limit 2) → In Review → Done.
- Iteration 1 (24 Oct 2026): Set up repository, CI, SQLite foundations and timer tests; clear Android/Windows setup issues. Record actual Git commits and screenshots as evidence.
- Iteration 2 (25 Oct 2026): Connected session, reflection and history flow; added insights/streak logic and iterated warm, more accessible UI through developer feedback. Reworked sound playback to a **non-functional future-work preview** to reduce plugin/debugging risk.
- Retrospective: The flexible Scrumban process accommodated rapid scope changes, but concentrated implementation in the final days compressed evaluation time. Do not invent stand-ups or earlier sprint dates.
- Evidence still needed: screenshot of updated board with WIP limit and issue states; screenshot of final CI; git history; final Gantt with **actual dates clearly separate** from the M1 planned baseline; real verification numbers.

## Planned-versus-actual graphic instructions

Create a *two-lane timeline* in the report: upper lane = original M1 plan, clearly labelled **M1 plan (Aug–Oct 2025, as submitted)**; lower lane = actual M2 work (24–25 Oct 2026, plus any later verified dates). Because the dates are from different years, **do not overlay these as if they were concurrent**. A paired table or small-multiple Gantt is more honest than one bar chart on a shared date axis.
