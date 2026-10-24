# FocusFlow — Final Android reliability check sheet

**Project:** AUT COMP826 Milestone 2 | **Developer:** project author | **Device:** Android Studio emulator, API 37 (from supplied run logs/screenshots) | **Date:** 25 October 2026 | **Tested commit:** `8eab48b` (CI #6 green).

**Evidence rules:** A passing Flutter test does not automatically prove every Android lifecycle behaviour. Record actual observations; leave cells blank until performed. This is a developer verification record, not an independent user study.

## Already verified (do not repeat)

| ID | Requirement | Method and observed evidence | Status |
|---|---|---|---|
| R01 | App runs with connectivity disabled | Airplane mode / Wi-Fi and mobile data disabled; Home, timer, History, Insights, Tips were displayed in user's Android screenshots | PASS for the demonstrated Android emulator paths |
| R02 | Session history and reflection persist offline | Created 6:27 AM session, ended early after 12 seconds, saved Choice reflection; closed/reopened offline; 6:32 AM screenshot showed retained session and reflection | PASS, screenshot `14_Offline_Persistence_Test.png` (verify local file exists) |
| R03 | Local notification delivered without tapping test button | Settings scheduled for 6:04 AM, notification shown at 6:04 AM on emulator | PASS for one Android scheduling trial, screenshots #12 and #13 |
| R04 | Large-text screen layout handles maximum font scaling | Reflection mood-card bottom overflow 6px and Insights header right overflow 2px reproduced; corrected and visually retested, both no overflow indicators | PASS for corrected areas, screenshot #15 |
| R05 | Automated static analysis and tests | 25 Oct: `flutter analyze` no issues, `flutter test` 58 passed; GitHub Actions #6 green (`8eab48b`) | PASS at that revision |

## Short remaining check sequence (no extra screenshots unless a failure occurs)

Start **one new 15-minute session** on your existing Android emulator. Use the phone timer displayed in-app and a separate stopwatch/clock only when needed.

| ID | Action | Expected behaviour to examine | Actual result | Pass / Fail / Limitation |
|---|---|---|---|---|
| R06 | Start a session; tap `Phone` exactly once; end early; skip reflection; view History | In-session count increases to 1; History for this session reads `Distractions noted: 1` | [fill] | [fill] |
| R07 | During a fresh session, pause for approximately 15 seconds then resume | Timer does not keep decreasing while paused; resumes afterwards | [fill] | [fill] |
| R08 | During a fresh running session, send emulator Home for ~30 seconds, reopen FocusFlow | Describe **actual behaviour**; compare countdown before/after. Do not assume desired background semantics until observed | [fill] | [fill] |
| R09 | Set default focus duration to 30 minutes; fully close/relaunch; start a new session | New session uses saved 30-minute preference | [fill] | [fill] |
| R10 | With reminders enabled, turn them off, close/reopen Settings | Off state persists and previously scheduled daily reminder is cancelled (verify app state; cancellation not directly proven by merely seeing switch off) | [fill] | [fill] |
| R11 | Open History to inspect old `Not yet ended` sessions | Record current interrupted-session behaviour accurately | Earlier records labelled `Not yet ended` after development restarts | KNOWN LIMITATION / recovery not verified |

**Potential limitations and fixes to report honestly:** interrupted-session recovery; inexact Android scheduled alarm delivery; only one emulator tested; no iOS device validation; screenshot comparison does not establish accessibility for screen readers.

**Quick manual results message to ChatGPT:** `R06 [pass/fail], R07 [pass/fail], R08 [what happened], R09 [pass/fail], R10 [pass/fail]`.
