# FocusFlow — Requirements-to-evidence matrix (Milestone 1 → Milestone 2)

**Interpretation:** Evidence is only as strong as the reported test or screenshot. PASS means the specified observed path passed, not every possible case.

| ID | Promised requirement | Implementation + test evidence | Status | Limitation |
|---|---|---|---|---|
| FR01 | Flexible focus session | SessionScreen + SessionPresenter; 15-min completion, pause/resume/background; 58-test suite | PASS observed | Unexpected exit not required to auto-complete |
| FR02 | One-tap distraction log | DistractionRepository; Phone one-tap manual test, History observed earlier | PASS observed | Latest trial tap count/time not logged |
| FR03 | Optional reflection | ReflectionPresenter/Repository; prompt and SQLite persistence verified | PASS observed | No formal external-user validation |
| FR04 | Local history | SessionRepository and History UI; offline restart screenshots | PASS observed | No extensive high-volume history test |
| FR05 | Weekly insights | Weekly Insights displayed offline; automated tests reported passing | IMPLEMENTED/OBSERVED | Hand-calculated independent 7-day dataset reconciliation not recorded |
| FR06 | Gentle streak/reward | Streak logic, supportive completion messaging | IMPLEMENTED/OBSERVED | Missed-day boundary not independently reverified in this checkpoint |
| FR07 | Static study tips | Tips view loaded offline on emulator | PASS observed | No measured learning benefit |
| FR08 | Reminder/settings | Scheduled Android reminder 6:04 AM, preferences and default duration | PASS observed | Only one scheduled delivery documented; iOS not tested |
| NFR Offline | No network required for core study flow | Airplane-mode navigation and local History persistence | PASS Android | Network-traffic audit not performed |
| NFR Privacy | Local-first/no account | SQLite architecture and tested saves | DESIGN + OBSERVED | Encryption and threat model unverified |
| NFR Accessibility | Comfortable large text/low overload | Two discovered overflows fixed and retested at large font | PARTIAL verified | TalkBack/actual accessibility study not performed |
| NFR Cross-platform | Flutter design | Android API 37 emulator run | ANDROID ONLY | iOS untested |
| NFR Performance | Responsive and appropriately sized app | Coarse 15-min timing cross-check | PARTIAL | App size, frame times, power and startup unmeasured |

**Data integrity note:** Older records marked “Not yet ended” reflect session records that were started but not explicitly completed, consistent with developer restarts and exit behaviour. Do not call this a demonstrated crash. The user confirmed minimising does not disrupt their session.

**Report mapping:** cite this matrix in the evaluation section, cite `docs/uml/` diagrams for technical design, `docs/process/` for development process, and reference actual device screenshots by their real filenames only after checking they exist in the final repository.
