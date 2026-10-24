# FocusFlow — Milestone 2 evaluation: recorded outcomes

**Date:** 25 October 2026 (NZDT)  
**Developer:** project author  
**Environment:** Android Studio emulator (API 37, based on earlier run evidence); Windows Flutter development  
**Evidence basis:** developer's reported device verification, supplied screenshots, local test output and GitHub Actions evidence. These observations are from development, not an independent usability trial.  
**Source revision:** record the *final* `git rev-parse --short HEAD` when the report is submitted. Existing automated test/CI evidence corresponds to `8eab48b` (CI #6); do not attribute later edits to that test run.

## Method 1 — PACMAD mobile usability

PACMAD considers effectiveness, efficiency, satisfaction, learnability, memorability, errors and cognitive load (Harrison et al., 2013). I adapted three user tasks and additional checks to the developer's own Android emulator session. Only **one developer** participated; there is no sample of external users.

| Task | Observable endpoint | Actual developer-reported result | Trial count | Actual seconds/taps |
|---|---|---|---:|---|
| P01 | Start a 15-minute focus session | Successfully started and ran the complete 15-minute session | 1 | Not recorded separately |
| P02 | Tap `Phone` once and verify distraction counter | Passed according to developer's manual test; no numeric screenshots supplied for this latest trial | 1 | Not recorded separately |
| P03 | On session completion, access optional reflection, save and check History | Completed session prompted reflection; developer confirmed reflection and History behaviour | 1 | Not recorded separately |

**Task completion within this small developer test: 3/3 = 100%.** This is a within-session **task-success proportion**, not a usability score or user-population success estimate. The developer also checked pause/resume, approximately 30-second backgrounding, and retained default duration/settings, reporting each passed. A personal phone served as an independent reference for the complete 15-minute countdown; the numerical timing difference was **not recorded**. Consequently I cannot quote timing error, average task duration, tap counts or a precision percentage.

| PACMAD characteristic | Evidence gathered | Interpretation / boundary |
|---|---|---|
| Effectiveness | All 3 task end states achieved | PASS for this single developer session only |
| Efficiency | Tasks completed; neither interaction seconds nor tap counts retained | Not quantitatively evaluated |
| Satisfaction | No formal post-task response or questionnaire | Not measured |
| Learnability | Developer familiar with app after extensive development | First-time learnability not established |
| Memorability | No delayed independent task repetition | Not measured |
| Errors | No task failures reported; error-event counts not logged | No error-rate estimate |
| Cognitive load | Simplified screens; large-text defects detected and fixed | No workload rating or cognitive-load assessment; only design rationale |

**Validity:** Prior exposure creates familiarity bias. Testing on a desktop-hosted emulator differs from use on a physical handset. No participants representing the intended neurodivergent student population were enrolled, so I make no general claim about their experience.

## Method 2 — ISO/IEC 25010:2023 software product quality

ISO/IEC 25010:2023 identifies nine product-quality characteristics. I assessed relevant observable aspects and explicitly record what was not measured.

| Characteristic | Actual evidence | Assessment boundary |
|---|---|---|
| Functional suitability | 58 automated Flutter tests passed; developer exercised complete 15-minute focus journey, distraction, reflection/history, settings and reminders | Tested scenarios passed; not exhaustive correctness |
| Performance efficiency | Entire 15-minute countdown cross-checked against developer's phone; no numeric error logged | Only coarse timer observation. APK size, CPU, memory, battery, rendering and cold launch **not measured** |
| Compatibility | Runs in tested Android emulator API 37 | No broad device/Android-version matrix |
| Interaction capability | Enlarged-text test exposed 6-pixel Reflection overflow and 2-pixel Insights overflow; both corrected and visually retested | Demonstrated accessibility improvement; TalkBack, target sizing and independent user tests unmeasured |
| Reliability | Offline session/reflection/history persistence verified after app reopen; background and pause/resume reported successful; notification delivered at scheduled 6:04 AM | Android emulator observations only; abandoned sessions are not automatically marked completed |
| Security | Local SQLite data storage, no account needed for normal flow | No encryption proof, permission/network audit or penetration test |
| Maintainability | MVP separation, repositories, 58 passing tests, `flutter analyze` clean, GitHub Actions CI #6 green | Development evidence rather than numerical maintainability score |
| Flexibility | Flutter/Dart project structure and duration preference settings | iOS build/run not verified; adaptability beyond observed configuration untested |
| Safety | App provides low-stakes study assistance, optional reflection and gentle messaging | No formal software safety assessment; not scored |

### Reliability evidence ledger

| ID | Observed check | Recorded outcome |
|---|---|---|
| E01 | App opens and key screens operate in airplane mode | PASS; screenshot evidence |
| E02 | Session and reflection remain in local History after app close/reopen while offline | PASS; screenshot evidence |
| E03 | Daily Android reminder arrives on configured time | PASS in one 6:04 AM trial; screenshots |
| E04 | Maximum-text UI overflow before/after repairs | Two faults identified, corrected and visually rechecked |
| E05 | Automated static analysis and unit/widget suite | PASS, `flutter analyze` clean, 58 tests, CI #6 green at recorded revision |
| E06 | Continuous 15-minute session against phone stopwatch | PASS as reported; numerical error unrecorded |
| E07 | Distraction button/count | PASS as reported in developer's final manual test |
| E08 | Pause/resume; application minimised for around 30 seconds | PASS as reported in developer's final manual test |
| E09 | Completion reflection prompt and saved History entry | PASS as reported in developer's final manual test |
| E10 | Default session duration persists when reopening Settings | PASS as reported in developer's final manual test |

**Interpretation:** The result is a functioning, locally persistent Android prototype with tested primary flows and a documented accessibility defect/fix cycle. It is **not** evidence that every ISO/IEC 25010 characteristic is compliant or that PACMAD user experience has been demonstrated with representative users.

### Actionable limitations and next generation

1. Test on physical low-end Android devices and iOS to verify cross-platform behavior, touch affordances, performance and resource consumption.
2. Conduct ethical task testing with consenting external users; gather seconds, taps, wrong actions, effort, satisfaction and a delayed repeat to cover the unmeasured PACMAD dimensions.
3. Add repeatable APK-size, cold-launch and frame-duration measurements, with explicit target thresholds.
4. Define and document the intentional rule for users who Back/exit an active session; if future user research supports it, add a confirmation or recovery option without silently counting an unfinished session as complete.
5. Add TalkBack semantics/focus-order review and accessible touch-target checks; retain the before/after font-overflow findings as a regression test target.
6. Audit OS minimum targets, permissions, and data protection rather than assuming a local SQLite database is encrypted.

## Sources

Harrison, R., Flood, D., & Duce, D. (2013). Usability of mobile applications: Literature review and rationale for a new usability model. *Journal of Interaction Science, 1*, Article 1. https://doi.org/10.1186/2194-0827-1-1

International Organization for Standardization & International Electrotechnical Commission. (2023). *Systems and software engineering — Systems and software Quality Requirements and Evaluation (SQuaRE) — Product quality model* (ISO/IEC Standard No. 25010:2023). https://www.iso.org/standard/78176.html
